/** Rental rules, independent of rendering and browser persistence.
 * Demo roles are workflow inputs, not a security or authentication boundary.
 */
import { movies } from "./catalog.js";
/** Create independent seed data for a new demo or an explicit reset. */
export function initial() {
  return {
    version: 1,
    movies: structuredClone(movies),
    members: [{ id: "member-1", name: "Demo Member", queue: [] }],
    rentals: [],
  };
}
const fail = (message) => {
  throw Error(message);
};
const text = (v, max = 200) =>
  String(v ?? "")
    .trim()
    .slice(0, max);
/** Allow local posters, supported uploads, and credential-free HTTPS images. */
export function imageURL(value) {
  if (!value) return "";
  if (/^assets\/posters\/[A-Za-z0-9_.-]+$/.test(value)) return value;
  if (
    /^data:image\/(jpeg|png|webp);base64,[A-Za-z0-9+/=]+$/.test(value) &&
    value.length < 1500000
  )
    return value;
  try {
    const u = new URL(value);
    return u.protocol === "https:" && !u.username && !u.password ? u.href : "";
  } catch {
    return "";
  }
}
/** Both mailed and watched rentals occupy the member's one at-home slot. */
export function activeRental(state, member) {
  return state.rentals.find(
    (r) => r.member === member && ["mailed", "watched"].includes(r.status),
  );
}
/**
 * Apply one action to a clone. Invalid actions throw before the caller saves.
 * @param {object} current - Last successfully saved state.
 * @param {object} action - Command with type, member, role and operation fields.
 * @returns {object} A new state; current remains unchanged.
 */
export function transition(current, action) {
  const s = structuredClone(current),
    a = action,
    now = a.now || new Date().toISOString();
  const member = () =>
    s.members.find((u) => u.id === a.member) || fail("Choose a valid member.");
  const movie = () =>
    s.movies.find((m) => m.id === a.movie) ||
    fail("This movie is not available.");
  const admin = () =>
    a.role === "admin" ||
    fail("Switch to the demo admin workspace for this action.");
  // Skip inactive queued titles without deleting them; keep their original order.
  function dispatch(u) {
    if (activeRental(s, u.id)) return null;
    const index = u.queue.findIndex((id) =>
      s.movies.some((m) => m.id === id && m.active),
    );
    if (index < 0) return null;
    const id = u.queue.splice(index, 1)[0];
    const rental = {
      id: a.id || "rental-" + crypto.randomUUID(),
      member: u.id,
      movie: id,
      status: "mailed",
      mailedAt: now,
      watchedAt: null,
      returnedAt: null,
    };
    s.rentals.push(rental);
    return rental;
  }
  switch (a.type) {
    case "member-add": {
      admin();
      const name = text(a.name, 70);
      if (!name) fail("Enter a member name.");
      if (s.members.length >= 50)
        fail("This demo supports up to 50 local profiles.");
      if (!a.id || s.members.some((u) => u.id === a.id))
        fail("Choose a unique profile ID.");
      s.members.push({ id: a.id, name, queue: [] });
      break;
    }
    case "queue-add": {
      const u = member(),
        m = movie();
      if (!m.active) fail("This title is currently inactive.");
      if (u.queue.includes(m.id)) fail("This movie is already in your queue.");
      if (activeRental(s, u.id)?.movie === m.id)
        fail("You already have this movie at home.");
      u.queue.push(m.id);
      break;
    }
    case "queue-remove": {
      const u = member();
      u.queue = u.queue.filter((id) => id !== a.movie);
      break;
    }
    case "queue-move": {
      const u = member(),
        from = u.queue.indexOf(a.movie),
        to = from + a.direction;
      if (
        ![-1, 1].includes(a.direction) ||
        from < 0 ||
        to < 0 ||
        to >= u.queue.length
      )
        fail("This movie cannot move any further.");
      [u.queue[from], u.queue[to]] = [u.queue[to], u.queue[from]];
      break;
    }
    case "dispatch": {
      admin();
      const u = member();
      if (activeRental(s, u.id))
        fail("This member already has a movie at home.");
      if (!dispatch(u))
        fail("The queue has no active movies ready to dispatch.");
      break;
    }
    case "watch": {
      member();
      const r = s.rentals.find(
        (r) => r.id === a.rental && r.member === a.member,
      );
      if (!r || r.status !== "mailed")
        fail("Only a dispatched rental can be marked as watched.");
      r.status = "watched";
      r.watchedAt = now;
      break;
    }
    // Completing a watched rental frees the at-home slot and sends the next title.
    case "return": {
      admin();
      const u = member(),
        r = s.rentals.find((r) => r.id === a.rental && r.member === u.id);
      if (!r || r.status !== "watched")
        fail(
          "The member must mark this rental as watched before it can be returned.",
        );
      r.status = "returned";
      r.returnedAt = now;
      dispatch(u);
      break;
    }
    // Soft deactivation preserves IDs referenced by queues and rental history.
    case "movie-toggle": {
      admin();
      const m = movie();
      m.active = !m.active;
      break;
    }
    case "movie-save": {
      admin();
      const p = a.values || {},
        title = text(p.title),
        genre = text(p.genre, 40),
        year = p.year === "" || p.year == null ? null : Number(p.year);
      if (!title || !genre) fail("Title and genre are required.");
      if (
        year !== null &&
        (!Number.isInteger(year) || year < 1888 || year > 2100)
      )
        fail("Enter a valid release year.");
      const image = imageURL(p.image);
      if (p.image && !image)
        fail("Use a valid HTTPS image or a supported poster image.");
      const values = {
        title,
        genre,
        year,
        image,
        plot: text(p.plot, 2500),
        director: text(p.director),
        actors: text(p.actors, 500),
        country: text(p.country, 100),
      };
      if (a.movie) {
        Object.assign(movie(), values);
      } else {
        if (!a.id || s.movies.some((m) => m.id === a.id))
          fail("Choose a unique movie ID.");
        s.movies.push({ id: a.id, ...values, active: true });
      }
      break;
    }
    default:
      fail("Unknown action.");
  }
  return s;
}
/** Check stored/imported state shape and cross-record references before use. */
export function validate(s) {
  if (
    !s ||
    s.version !== 1 ||
    !Array.isArray(s.movies) ||
    !Array.isArray(s.members) ||
    !Array.isArray(s.rentals) ||
    s.members.length < 1 ||
    s.members.length > 50 ||
    s.movies.length > 500 ||
    s.rentals.length > 5000
  )
    return false;
  const unique = (rows) => new Set(rows.map((x) => x.id)).size === rows.length;
  if (![s.movies, s.members, s.rentals].every(unique)) return false;
  if (
    !s.movies.every(
      (m) =>
        typeof m.id === "string" &&
        typeof m.title === "string" &&
        typeof m.genre === "string" &&
        typeof m.active === "boolean" &&
        typeof m.image === "string" &&
        (!m.image || imageURL(m.image)),
    )
  )
    return false;
  if (
    !s.members.every(
      (u) =>
        typeof u.id === "string" &&
        typeof u.name === "string" &&
        Array.isArray(u.queue) &&
        new Set(u.queue).size === u.queue.length &&
        u.queue.every((id) => s.movies.some((m) => m.id === id)),
    )
  )
    return false;
  if (
    !s.rentals.every(
      (r) =>
        typeof r.id === "string" &&
        s.movies.some((m) => m.id === r.movie) &&
        s.members.some((u) => u.id === r.member) &&
        ["mailed", "watched", "returned"].includes(r.status),
    )
  )
    return false;
  return s.members.every(
    (u) =>
      s.rentals.filter((r) => r.member === u.id && r.status !== "returned")
        .length <= 1,
  );
}
