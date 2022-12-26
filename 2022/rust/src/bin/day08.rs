use aoc2022;
use itertools::Itertools;

type Grid = Vec<Vec<isize>>;
type VisibilityMap = Vec<Vec<(isize, isize, isize, isize)>>;

fn pop_while<T>(stack: &mut Vec<T>, predicate: impl Fn(&T) -> bool) {
    while let Some(val) = stack.last() {
        if predicate(val) {
            stack.pop();
        } else {
            break;
        }
    }
}

fn compute_visibility_map(grid: &Grid) -> VisibilityMap {
    // (top visibility, right visibility, bottom visibility, left visibility)
    let d = vec![(0, 0, 0, 0); grid[0].len()];
    let mut visibility_map = vec![d; grid.len()];
    let mut visible_peaks: Vec<(isize, isize)>;

    for row in 0..grid.len() {
        visible_peaks = vec![(11, -1)];
        for col in 0..grid[row].len() {
            let height = grid[row][col];
            pop_while(&mut visible_peaks, |(peak_height, _peak_col)| {
                *peak_height < height
            });
            let &(_peak_height, peak_col) = visible_peaks.last().expect("Something went wrong");
            visibility_map[row][col].3 = peak_col;
            visible_peaks.push((height, col as isize));
        }

        visible_peaks = vec![(11, grid[row].len() as isize)];
        for col in (0..grid[row].len()).rev() {
            let height = grid[row][col];
            pop_while(&mut visible_peaks, |(peak_height, _peak_col)| {
                *peak_height < height
            });
            let &(_peak_height, peak_col) = visible_peaks.last().expect("Something went wrong");
            visibility_map[row][col].1 = peak_col;
            visible_peaks.push((height, col as isize));
        }
    }
    for col in 0..grid[0].len() {
        visible_peaks = vec![(11, -1)];
        for row in 0..grid.len() {
            let height = grid[row][col];
            pop_while(&mut visible_peaks, |(peak_height, _peak_col)| {
                *peak_height < height
            });
            let &(_peak_height, peak_row) = visible_peaks.last().expect("Something went wrong");
            visibility_map[row][col].0 = peak_row;
            visible_peaks.push((height, row as isize));
        }

        visible_peaks = vec![(11, grid.len() as isize)];
        for row in (0..grid.len()).rev() {
            let height = grid[row][col];
            pop_while(&mut visible_peaks, |(peak_height, _peak_col)| {
                *peak_height < height
            });
            let &(_peak_height, peak_row) = visible_peaks.last().expect("Something went wrong");
            visibility_map[row][col].2 = peak_row;
            visible_peaks.push((height, row as isize));
        }
    }
    visibility_map
}

fn is_visible(visibility_map: &VisibilityMap, row: usize, col: usize) -> bool {
    let (n_rows, n_cols) = (visibility_map.len(), visibility_map[0].len());
    let (vt, vr, vb, vl) = visibility_map[row][col];
    vt == -1 || vb == n_rows as isize || vl == -1 || vr == n_cols as isize
}

fn scenic_score(visibility_map: &VisibilityMap, row: usize, col: usize) -> usize {
    let (n_rows, n_cols) = (visibility_map.len(), visibility_map[0].len());
    let (tp, rp, bp, lp) = visibility_map[row][col];
    (row - tp.max(0) as usize)
        * ((rp as usize).min(n_cols - 1) - col)
        * ((bp as usize).min(n_rows - 1) - row)
        * (col - lp.max(0) as usize)
}

fn part1() {
    let grid = aoc2022::io::read_matrix(|c| c.to_digit(10).expect("Invalid digit") as isize);
    let visibility_map = compute_visibility_map(&grid);
    let mut count = 0;
    for row in 0..grid.len() {
        for col in 0..grid[row].len() {
            if is_visible(&visibility_map, row, col) {
                count += 1;
            }
        }
    }
    println!("There are {} trees visible from outside the grid", count);
}

fn part2() {
    let grid = aoc2022::io::read_matrix(|c| c.to_digit(10).expect("Invalid digit") as isize);
    let visibility_map = compute_visibility_map(&grid);
    let max_score = (0..grid.len())
        .cartesian_product(0..grid[0].len())
        .map(|(r, c)| scenic_score(&visibility_map, r, c))
        .max()
        .unwrap();
    println!("The best scenic score is {}", max_score);
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
