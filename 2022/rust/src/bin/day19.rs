use itertools::{izip, Itertools};
use std::convert::TryInto;

use aoc2022;

type Res = [usize; 4];

#[derive(Clone, Debug)]
struct BluePrint {
    ore: Res,
    clay: Res,
    obsidian: Res,
    geode: Res,
    // How much units of that resouce can be consumed per instant, at most
    max_consumption: Res,
}

impl BluePrint {
    fn new(ore: Res, clay: Res, obsidian: Res, geode: Res) -> Self {
        let a = vec![ore, clay, obsidian, geode];
        let max_consumption = (0..4)
            .map(|resource| a.iter().map(|robot| robot[resource]).max().expect("what"))
            .collect_vec()
            .try_into()
            .expect("aha");
        Self {
            ore,
            clay,
            obsidian,
            geode,
            max_consumption,
        }
    }

    fn get_bom(self: &Self, index: usize) -> Res {
        match index {
            0 => self.ore,
            1 => self.clay,
            2 => self.obsidian,
            3 => self.geode,
            _ => panic!("invalid blueprint index"),
        }
    }
}

#[derive(Clone, Debug)]
struct State {
    resources: Res,
    production: Res,
}

fn time_required(state: &State, bom: Res) -> usize {
    // println!("Calculating time for {:?} {:?}", bom, state);
    let time_to_enough_resources = izip!(state.resources, state.production, bom)
        .map(|(available, production, required)| {
            if required <= available {
                return 0;
            }
            if production == 0 {
                return 1_000_000;
            }
            (required - available + production - 1) / production
        })
        .max()
        .expect("Reality is a lie");
    time_to_enough_resources + 1
}

static mut INVOKATIONS: usize = 0;

// how much time before turns into a geode
fn geode_delay_factor(_blueprint: &BluePrint, robot: usize) -> usize {
    match robot {
        0 => 1,
        1 => 2,
        2 => 1,
        3 => 0,
        _ => panic!("Unexpected robot index"),
    }
}

fn too_much_production(blueprint: &BluePrint, state: &State, robot: usize) -> bool {
    if robot == 3 {
        return false;
    }
    state.production[robot] > blueprint.max_consumption[robot]
}

fn is_useless(
    time_limit: usize,
    blueprint: &BluePrint,
    state: &State,
    robot: usize,
    minute: usize,
    time_to_build: usize,
) -> bool {
    minute + time_to_build + geode_delay_factor(blueprint, robot) > time_limit
        || too_much_production(blueprint, state, robot)
}

fn best_option(time_limit: usize, blueprint: &BluePrint, state: &State, minute: usize) -> usize {
    unsafe {
        INVOKATIONS += 1;
    }

    (0..4)
        .map(|robot| {
            let bom = blueprint.get_bom(robot);
            let t = time_required(state, bom);
            if minute + t > time_limit || is_useless(time_limit, blueprint, state, robot, minute, t)
            {
                state.resources[3] + state.production[3] * (time_limit + 1 - minute)
            } else {
                let mut new_state = state.clone();
                for i in 0..4 {
                    new_state.resources[i] = new_state.resources[i] + new_state.production[i] * t
                        - blueprint.get_bom(robot)[i]
                }
                new_state.production[robot] += 1;
                best_option(time_limit, blueprint, &new_state, minute + t)
            }
        })
        .max()
        .expect("Reality is a lie")
}

fn parse_blueprint(line: &str) -> BluePrint {
    let (ore_ore, clay_ore, obsidian_ore, obsidian_clay, geode_ore, geode_obsidian) = line
        .split_ascii_whitespace()
        .map(|word| word.parse::<usize>())
        .filter_map(|v| v.ok())
        .collect_tuple()
        .expect("Invalid blueprint");
    BluePrint::new(
        [ore_ore, 0, 0, 0],
        [clay_ore, 0, 0, 0],
        [obsidian_ore, obsidian_clay, 0, 0],
        [geode_ore, 0, geode_obsidian, 0],
    )
}

fn part1() {
    let initial_state = State {
        resources: [0; 4],
        production: [1, 0, 0, 0],
    };
    let total_quality_level: usize = aoc2022::io::iterate_lines()
        .map(|l| parse_blueprint(&l))
        .map(|b| best_option(24, &b, &initial_state, 1))
        .enumerate()
        .inspect(|(i, x)| unsafe {
            eprintln!(
                "{:?} with blueprint {} (using {} recursive calls)",
                x, i, INVOKATIONS
            );
            INVOKATIONS = 0;
        })
        .map(|(blueprint_index, geodes)| geodes * (blueprint_index + 1))
        .sum();

    println!("Total quality level is {}", total_quality_level);
}

fn part2() {
    let initial_state = State {
        resources: [0; 4],
        production: [1, 0, 0, 0],
    };
    let res: usize = aoc2022::io::iterate_lines()
        .take(3)
        .map(|l| parse_blueprint(&l))
        .map(|b| best_option(32, &b, &initial_state, 1))
        .enumerate()
        .inspect(|(i, x)| unsafe {
            eprintln!(
                "{:?} with blueprint {} (using {} recursive calls)",
                x, i, INVOKATIONS
            );
            INVOKATIONS = 0;
        })
        .map(|(_, geodes)| geodes)
        .product();
    println!(
        "Product of largest number of geodes first 3 blueprints is {}",
        res
    );
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
