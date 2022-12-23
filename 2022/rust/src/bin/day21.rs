use itertools::Itertools;
use std::collections::HashMap;

use aoc2022;

type Monkey = String;

#[derive(Clone)]
enum Job {
    Num(isize),
    Add(Monkey, Monkey),
    Sub(Monkey, Monkey),
    Mul(Monkey, Monkey),
    Div(Monkey, Monkey),
}

fn parse_line(line: &str) -> (Monkey, Job) {
    let (monkey, job) = line.split(":").collect_tuple().expect("Invalid line");
    let monkey = String::from(monkey);
    match job.split_ascii_whitespace().collect_vec() {
        vec if vec.len() == 1 => {
            let n = vec[0].parse().expect("Invalid input line");
            (monkey, Job::Num(n))
        }
        vec if vec.len() == 3 => {
            let (monkey1, operator, monkey2) =
                vec.into_iter().collect_tuple().expect("Invalid line");
            match operator {
                "+" => (monkey, Job::Add(monkey1.to_owned(), monkey2.to_owned())),
                "-" => (monkey, Job::Sub(monkey1.to_owned(), monkey2.to_owned())),
                "*" => (monkey, Job::Mul(monkey1.to_owned(), monkey2.to_owned())),
                "/" => (monkey, Job::Div(monkey1.to_owned(), monkey2.to_owned())),
                op => panic!("Invalid operation {}", op),
            }
        }
        _ => panic!("Invalid line"),
    }
}

fn resolve(tree: &HashMap<Monkey, Job>, monkey: &Monkey) -> isize {
    match tree.get(monkey).expect("reference to unknown monkey") {
        Job::Num(n) => *n,
        Job::Add(monkey1, monkey2) => resolve(tree, monkey1) + resolve(tree, monkey2),
        Job::Sub(monkey1, monkey2) => resolve(tree, monkey1) - resolve(tree, monkey2),
        Job::Mul(monkey1, monkey2) => resolve(tree, monkey1) * resolve(tree, monkey2),
        Job::Div(monkey1, monkey2) => resolve(tree, monkey1) / resolve(tree, monkey2),
    }
}

fn backsolve(
    tree: &HashMap<Monkey, Job>,
    human_path: &Vec<&Monkey>,
    monkey: &Monkey,
    total: isize,
) -> isize {
    eprintln!("Monkey {} should yell {}", monkey, total);
    match tree.get(monkey).expect("reference to unknown monkey") {
        Job::Num(_human) => total,
        Job::Add(monkey1, monkey2) => {
            if human_path.contains(&monkey1) {
                let n = resolve(tree, monkey2);
                backsolve(tree, human_path, monkey1, total - n)
            } else {
                let n = resolve(tree, monkey1);
                backsolve(tree, human_path, monkey2, total - n)
            }
        }
        Job::Sub(monkey1, monkey2) => {
            if human_path.contains(&monkey1) {
                let n = resolve(tree, monkey2);
                backsolve(tree, human_path, monkey1, total + n)
            } else {
                let n = resolve(tree, monkey1);
                backsolve(tree, human_path, monkey2, n - total)
            }
        }
        Job::Mul(monkey1, monkey2) => {
            if human_path.contains(&monkey1) {
                let n = resolve(tree, monkey2);
                backsolve(tree, human_path, monkey1, total / n)
            } else {
                let n = resolve(tree, monkey1);
                backsolve(tree, human_path, monkey2, total / n)
            }
        }
        Job::Div(monkey1, monkey2) => {
            if human_path.contains(&monkey1) {
                let n = resolve(tree, monkey2);
                backsolve(tree, human_path, monkey1, total * n)
            } else {
                let n = resolve(tree, monkey1);
                backsolve(tree, human_path, monkey2, n / total)
            }
        }
    }
}

fn part1() {
    let mut mem: HashMap<Monkey, Job> = HashMap::new();
    for (monkey, job) in aoc2022::io::iterate_lines().map(|line| parse_line(&line)) {
        mem.insert(monkey, job);
    }
    let res = resolve(&mem, &String::from("root"));
    println!("Monkey 'root' will yell {}", res);
}

fn part2() {
    let mut mem: HashMap<Monkey, Job> = HashMap::new();
    let mut parent: HashMap<Monkey, Monkey> = HashMap::new();
    for (monkey, job) in aoc2022::io::iterate_lines().map(|line| parse_line(&line)) {
        mem.insert(monkey.clone(), job.clone());
        match job {
            Job::Num(_) => {}
            Job::Add(m1, m2) | Job::Sub(m1, m2) | Job::Mul(m1, m2) | Job::Div(m1, m2) => {
                parent
                    .insert(m1, monkey.clone())
                    .and_then::<(), _>(|_x| panic!("Not a tree"));
                parent
                    .insert(m2, monkey.clone())
                    .and_then::<(), _>(|_x| panic!("Not a tree"));
            }
        }
    }

    let humn = "humn".to_string();
    let root = "root".to_string();
    let mut human_path: Vec<&Monkey> = vec![&humn];
    let mut p = parent.get("humn").expect("No human");
    while p != "root" {
        human_path.push(p);
        p = parent.get(p).expect("??")
    }

    let res = match mem.get(&root).expect("No root!") {
        Job::Num(_) => panic!("Unexpected root as num"),
        Job::Add(m1, m2) | Job::Sub(m1, m2) | Job::Mul(m1, m2) | Job::Div(m1, m2) => {
            if human_path.contains(&m1) {
                let total = resolve(&mem, m2);
                backsolve(&mem, &human_path, m1, total)
            } else {
                let total = resolve(&mem, m1);
                backsolve(&mem, &human_path, m2, total)
            }
        }
    };
    println!("humn should yell {}", res);
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
