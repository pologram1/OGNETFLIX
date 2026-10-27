import test from "node:test";
import assert from "node:assert/strict";
import {
  initial,
  transition,
  validate,
  imageURL,
  activeRental,
} from "../src/js/model.js";
const action = (state, type, extra = {}) =>
  transition(state, { type, member: "member-1", role: "admin", ...extra });
test("queue ordering, duplicate protection and immutable failures", () => {
  let s = action(initial(), "queue-add", { movie: "300" });
  const before = JSON.stringify(s);
  assert.throws(() => action(s, "queue-add", { movie: "300" }), /already/);
  assert.equal(JSON.stringify(s), before);
  s = action(s, "queue-add", { movie: "paddington" });
  s = action(s, "queue-move", { movie: "paddington", direction: -1 });
  assert.deepEqual(s.members[0].queue, ["paddington", "300"]);
  assert.throws(() =>
    action(s, "queue-move", { movie: "paddington", direction: -1 }),
  );
});
test("rental lifecycle enforces permissions and auto-dispatches next title", () => {
  let s = action(initial(), "queue-add", { movie: "300" });
  s = action(s, "queue-add", { movie: "paddington" });
  assert.throws(() => action(s, "dispatch", { role: "member", id: "r1" }));
  s = action(s, "dispatch", { id: "r1" });
  assert.equal(activeRental(s, "member-1").movie, "300");
  assert.throws(() => action(s, "dispatch", { id: "r2" }));
  assert.throws(() => action(s, "queue-add", { movie: "300" }));
  assert.throws(() => action(s, "return", { rental: "r1", id: "r2" }));
  s = action(s, "watch", { rental: "r1", role: "member" });
  assert.throws(() =>
    action(s, "return", { rental: "r1", id: "r2", role: "member" }),
  );
  s = action(s, "return", { rental: "r1", id: "r2" });
  assert.equal(s.rentals[0].status, "returned");
  assert.equal(activeRental(s, "member-1").movie, "paddington");
  assert.deepEqual(s.members[0].queue, []);
  assert.ok(validate(s));
});
test("inactive titles remain queued and history survives edits", () => {
  let s = action(initial(), "queue-add", { movie: "300" });
  s = action(s, "queue-add", { movie: "paddington" });
  s = action(s, "movie-toggle", { movie: "300" });
  s = action(s, "dispatch", { id: "r1" });
  assert.equal(activeRental(s, "member-1").movie, "paddington");
  assert.deepEqual(s.members[0].queue, ["300"]);
  s = action(s, "movie-toggle", { movie: "300" });
  s = action(s, "watch", { rental: "r1" });
  s = action(s, "return", { rental: "r1", id: "r2" });
  s = action(s, "movie-toggle", { movie: "paddington" });
  assert.equal(s.rentals[0].movie, "paddington");
  assert.ok(validate(s));
});
test("profiles have separate queues and rental ownership", () => {
  let s = action(initial(), "member-add", {
    name: "Second member",
    id: "member-2",
  });
  s = action(s, "queue-add", { movie: "300" });
  s = action(s, "dispatch", { id: "r1" });
  assert.deepEqual(s.members[1].queue, []);
  assert.throws(() => action(s, "watch", { member: "member-2", rental: "r1" }));
});
test("catalog validation and corrupt saved data rejection", () => {
  assert.equal(imageURL("javascript:alert(1)"), "");
  assert.equal(imageURL("https://user:password@example.com/p.jpg"), "");
  assert.equal(imageURL("assets/posters/300.jpg"), "assets/posters/300.jpg");
  assert.throws(() =>
    action(initial(), "movie-save", {
      id: "new",
      values: { title: "New", genre: "Drama", year: 1000 },
    }),
  );
  assert.throws(() =>
    action(initial(), "movie-save", {
      role: "member",
      id: "new",
      values: { title: "New", genre: "Drama" },
    }),
  );
  const s = initial();
  s.movies.push({ ...s.movies[0] });
  assert.equal(validate(s), false);
  const t = initial();
  t.members[0].queue = ["missing"];
  assert.equal(validate(t), false);
});
