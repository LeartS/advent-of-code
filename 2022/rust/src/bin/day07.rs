use std::collections::{HashMap, HashSet};

use aoc2022;
use nom::branch::alt;
use nom::bytes::complete::{tag, take_while1};
use nom::character::complete::{alpha1, digit1, space1};
use nom::combinator::{eof, map};
use nom::sequence::{pair, separated_pair, tuple};
use nom::IResult;

#[derive(Debug, PartialEq)]
enum CdTarget {
    Root,
    Parent,
    Child(String),
}

#[derive(Debug, PartialEq)]
enum TerminalLine {
    Ls,
    Cd(CdTarget),
    File { size: usize, filename: String },
    Dir(String),
}

fn cd_target(i: &str) -> IResult<&str, CdTarget> {
    map(alt((tag(".."), tag("/"), alpha1)), |p| match p {
        ".." => CdTarget::Parent,
        "/" => CdTarget::Root,
        subpath => CdTarget::Child(subpath.to_string()),
    })(i)
}

fn cd(i: &str) -> IResult<&str, TerminalLine> {
    map(tuple((tag("$ cd "), cd_target)), |(_, target)| {
        TerminalLine::Cd(target)
    })(i)
}

fn ls(i: &str) -> IResult<&str, TerminalLine> {
    map(tag("$ ls"), |_| TerminalLine::Ls)(i)
}

fn dir(i: &str) -> IResult<&str, TerminalLine> {
    map(
        separated_pair(tag("dir"), space1::<&str, _>, alpha1),
        |(_, dirname)| TerminalLine::Dir(dirname.to_string()),
    )(i)
}

fn file(i: &str) -> IResult<&str, TerminalLine> {
    map(
        separated_pair(
            digit1,
            space1::<&str, _>,
            take_while1::<_, &str, _>(|c| c.is_alphabetic() || c == '.'),
        ),
        |(size_str, filename)| TerminalLine::File {
            size: size_str.parse::<usize>().unwrap(),
            filename: filename.to_string(),
        },
    )(i)
}

fn terminal_line(i: &str) -> IResult<&str, TerminalLine> {
    map(pair(alt((cd, ls, dir, file)), eof), |(line, _)| line)(i)
}

fn parse_terminal_line(i: &str) -> Result<TerminalLine, nom::Err<nom::error::Error<&str>>> {
    terminal_line(i).and_then(|(_, line)| Ok(line))
}

fn absolute_path(current_path: &Vec<String>, filename: &String) -> String {
    current_path.join("") + filename
}

struct State {
    directories: HashMap<String, usize>,
    current_path: Vec<String>,
    visited_files: HashSet<String>,
}

fn analyze_filesystem() -> HashMap<String, usize> {
    let initial_state = State {
        directories: HashMap::from([("/".to_string(), 0usize)]),
        current_path: Vec::new(),
        visited_files: HashSet::new(),
    };
    aoc2022::io::iterate_lines()
        .map(|line| parse_terminal_line(&line).expect("invalid line!"))
        .fold(initial_state, |mut state, line| -> State {
            match line {
                TerminalLine::Ls => state,
                TerminalLine::Cd(CdTarget::Root) => {
                    state.current_path = vec!["/".into()];
                    state
                }
                TerminalLine::Cd(CdTarget::Parent) => {
                    state.current_path.pop();
                    state
                }
                TerminalLine::Cd(CdTarget::Child(dirname)) => {
                    state.current_path.push(dirname + "/");
                    let a = state.current_path.join("");
                    if !state.directories.contains_key(&a) {
                        state.directories.insert(a, 0);
                    }
                    state
                }
                TerminalLine::Dir(_) => state,
                TerminalLine::File { size, filename } => {
                    let file_path = absolute_path(&state.current_path, &filename);
                    if !state.visited_files.contains(&file_path) {
                        for i in 1..=state.current_path.len() {
                            *state
                                .directories
                                .get_mut(&state.current_path[..i].join(""))
                                .expect("WHAT??") += size;
                        }
                        state.visited_files.insert(filename);
                    }
                    state
                }
            }
        })
        .directories
}

fn part1() {
    let res: usize = analyze_filesystem()
        .values()
        .filter(|&&v| v <= 100_000)
        .sum();
    println!("Sum of total sizes of directories <= 100000 is {}", res);
}

fn part2() {
    let directories = analyze_filesystem();
    let required = 30_000_000 - (70_000_000 - directories.get("/").expect("No root directory??"));
    let res = directories
        .values()
        .filter(|&&size| size >= required)
        .min()
        .expect("Mmmhhh...");
    println!(
        "Smallest directory that can be deleted to allow for updated has size {}",
        res
    );
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}

#[cfg(test)]
mod tests {
    use nom::combinator::not;

    use super::*;

    #[test]
    pub fn test_parse_cd_target() {
        assert_eq!(cd_target("/"), Ok(("", CdTarget::Root)));
        assert_eq!(cd_target(".."), Ok(("", CdTarget::Parent)));
        assert_eq!(cd_target("ab"), Ok(("", CdTarget::Child("ab".into()))));
    }

    #[test]
    pub fn test_terminal_line() {
        assert_eq!(terminal_line("ls"), Ok(("", TerminalLine::Ls)));
        assert_eq!(
            terminal_line("cd .."),
            Ok(("", TerminalLine::Cd(CdTarget::Parent)))
        );
        assert_eq!(
            terminal_line("dir abc"),
            Ok(("", TerminalLine::Dir("abc".into())))
        );
        assert_eq!(
            terminal_line("1234 ciao.txt"),
            Ok((
                "",
                TerminalLine::File {
                    filename: "ciao.txt".into(),
                    size: 1234
                }
            ))
        );
        assert_eq!(not(terminal_line)("cd"), Ok(("cd", ())));
    }
}
