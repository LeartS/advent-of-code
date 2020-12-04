use regex::Regex;
use lazy_static::lazy_static;
use std::{collections::HashSet, ops::RangeBounds};
use std::io::{self, Read};

fn has_required_fields(passport: &str) -> bool {
    let required_fields: HashSet<&str> = vec!["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]
        .into_iter()
        .collect();
    passport
        .split_whitespace()
        .map(|field| field.splitn(2, ':').next().expect("Invalid field"))
        .collect::<HashSet<&str>>()
        .is_superset(&required_fields)
}

fn validate_year<R: RangeBounds<usize>>(range: R, year_string: &str, ) -> bool {
    match year_string.parse::<usize>() {
        Ok(year) if range.contains(&year) => true,
        _ => false
    }
}

fn validate_height(hgt: &str) -> bool {
    lazy_static! {
        static ref HGT_RE: Regex = Regex::new(r"^(\d+)(cm|in)$").unwrap();
    }
    match HGT_RE.captures(hgt) {
        None => false,
        Some(captures) => {
            let amount: usize = captures.get(1).unwrap().as_str().parse().unwrap();
            let unit: &str = captures.get(2).unwrap().as_str();
            match (amount, unit) {
                (150..=193, "cm") => true,
                (59..=76, "in") => true,
                _ => false
            }
        }
    }
}

fn validate_field(fkey: &str, fvalue: &str) -> bool {
    lazy_static! {
        static ref HCL_RE: Regex = Regex::new(r"^#[0-9a-f]{6,6}$").unwrap();
        static ref ECL_RE: Regex = Regex::new(r"^(amb)|(blu)|(brn)|(gry)|(grn)|(hzl)|(oth)$").unwrap();
        static ref PID_RE: Regex = Regex::new(r"^\d{9,9}$").unwrap();
    }
    match fkey {
        "byr" => validate_year(1920..=2002, fvalue),
        "iyr" => validate_year(2010..=2020, fvalue),
        "eyr" => validate_year(2020..=2030, fvalue),
        "hgt" => validate_height(fvalue),
        "hcl" => HCL_RE.is_match(fvalue),
        "ecl" => ECL_RE.is_match(fvalue),
        "pid" => PID_RE.is_match(fvalue),
        "cid" => true,
        _ => false,
    }
}

fn has_valid_fields(passport: &str) -> bool {
    passport
        .split_whitespace()
        .all(|field| {
            let mut it = field.splitn(2, ':');
            match (it.next(), it.next()) {
                (Some(key), Some(value)) => validate_field(key, value),
                _ => false
            }
        })
}

fn count_valid_passports<V: Fn(&str) -> bool>(validator: V) -> usize {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Could not read from stdin!");
    let passports: Vec<&str> = buffer.split("\n\n").collect();
    passports.iter().filter(|&p| validator(p)).count()
}

fn part1() {
    let valid_passports_count = count_valid_passports(has_required_fields);
    println!("{} valid passports", valid_passports_count)
}

fn part2() {
    let valid_passports_count = count_valid_passports(|p| has_required_fields(p) && has_valid_fields(p));
    println!("{} valid passports", valid_passports_count)
}

pub fn main() {
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1(),
        Some(p) if p == "part2" => part2(),
        _ => println!("Please specify a part (part1 | part2)"),
    }
}
