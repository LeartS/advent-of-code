import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils/io as io_utils

const min = 200_000_000_000_000.0

const max = 400_000_000_000_000.0

// const min = 7.0

// const max = 27.0

pub type Line2D {
  // Pseudo-standard form: ax + by = c
  // (not necessarily normalized, but all integers)
  // a == 0 -> horizontal line
  // b == 0 -> vertical line
  Line2D(a: Int, b: Int, c: Int)
}

type Hailstone {
  Hailstone(
    position: #(Int, Int, Int),
    velocity: #(Int, Int, Int),
    path: Line2D,
  )
}

// Returns a 2D line from a 3D point and direction.
// Ignores the z components
pub fn line_from_3d_point_and_direction(
  point: #(Int, Int, Int),
  direction: #(Int, Int, Int),
) -> Line2D {
  let #(px, py, _pz) = point
  let #(dx, dy, _dz) = direction
  let a = dy
  let b = -dx
  let c = a * px + b * py
  Line2D(a, b, c)
}

fn parse_hailstone(hailstone_desc: String) -> Hailstone {
  let assert Ok(#(position, velocity)) =
    string.split_once(hailstone_desc, " @ ")
  let assert Ok([px, py, pz]) =
    position
    |> string.split(", ")
    |> list.map(string.trim)
    |> list.try_map(int.parse)
  let assert Ok([vx, vy, vz]) =
    velocity
    |> string.split(", ")
    |> list.map(string.trim)
    |> list.try_map(int.parse)
  let position = #(px, py, pz)
  let velocity = #(vx, vy, vz)
  let path = line_from_3d_point_and_direction(position, velocity)
  Hailstone(position, velocity, path)
}

pub type LinesIntersection2D {
  Parallel
  Collinear
  Point(x: Float, y: Float)
}

pub fn find_2d_lines_intersection(
  line_1: Line2D,
  line_2: Line2D,
) -> LinesIntersection2D {
  let Line2D(a: a1, b: b1, c: c1) = line_1
  let Line2D(a: a2, b: b2, c: c2) = line_2
  let determinant = a1 * b2 - a2 * b1
  let parallel = determinant == 0
  let collinear = parallel && a1 * c2 == a2 * c1
  case collinear, parallel {
    True, _ -> Collinear
    False, True -> Parallel
    False, False ->
      Point(
        x: int.to_float(b2 * c1 - b1 * c2) /. int.to_float(determinant),
        y: int.to_float(a1 * c2 - a2 * c1) /. int.to_float(determinant),
      )
  }
}

pub fn part1(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.map(parse_hailstone)
  |> list.combination_pairs()
  |> list.filter(fn(pair) {
    let #(first, second) = pair
    case find_2d_lines_intersection(first.path, second.path) {
      Collinear -> True
      Parallel -> False
      Point(x: x, y: y) -> {
        let in_bounds = x >=. min && x <=. max && y >=. min && y <=. max
        let future = {
          { x >=. int.to_float(first.position.0) == first.velocity.0 >= 0 } && {
            y >=. int.to_float(first.position.1) == first.velocity.1 >= 0
          } && {
            x >=. int.to_float(second.position.0) == second.velocity.0 >= 0
          } && {
            y >=. int.to_float(second.position.1) == second.velocity.1 >= 0
          }
        }
        in_bounds && future
      }
    }
  })
  |> list.length()
}

pub fn part2(input: String) -> Int {
  todo
}

pub fn main() {
  let assert Ok(input) = io_utils.read_stdin()
  io.println("Part 1: " <> int.to_string(part1(input)))
  //   io.println("Part 2: " <> int.to_string(part2(input)))
}
