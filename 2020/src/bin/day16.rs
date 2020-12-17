use itertools::Itertools;
use std::collections::HashSet;
use std::fmt;
use std::io::{self, BufRead};
use std::ops::RangeInclusive;

type Ticket = Vec<usize>;

#[derive(Debug, Eq, PartialEq, Hash)]
struct Field {
    name: String,
    rules: Vec<RangeInclusive<usize>>,
}

impl fmt::Display for Field {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.name)
    }
}

fn parse_field(line: &str) -> Field {
    let (name, rules) = line.splitn(2, ": ").collect_tuple().unwrap();
    let rules = rules
        .split(" or ")
        .map(|r| {
            let (min, max) = r
                .split("-")
                .map(|n| n.parse::<usize>().unwrap())
                .collect_tuple()
                .unwrap();
            min..=max
        })
        .collect_vec();
    Field {
        name: name.to_owned(),
        rules: rules.to_owned(),
    }
}

fn parse_ticket(line: &str) -> Ticket {
    line.trim()
        .split(',')
        .map(|n| n.parse::<usize>().unwrap())
        .collect_vec()
}

fn read_input() -> (Vec<Field>, Ticket, Vec<Ticket>) {
    let stdin = io::stdin();
    let fields = stdin
        .lock()
        .lines()
        .map(|l| l.unwrap())
        .take_while(|l| l.trim().len() > 0)
        .map(|l| parse_field(&l))
        .collect_vec();

    let mut buf = String::new();
    stdin.read_line(&mut buf).unwrap();
    buf.clear();

    stdin.read_line(&mut buf).unwrap();
    let my_ticket = parse_ticket(buf.as_str());

    stdin.read_line(&mut buf).unwrap();
    stdin.read_line(&mut buf).unwrap();
    let tickets = stdin
        .lock()
        .lines()
        .map(|l| parse_ticket(&l.unwrap()))
        .collect_vec();

    (fields, my_ticket, tickets)
}

fn within_constraints(field: &Field, value: usize) -> bool {
    field.rules.iter().any(|rule| rule.contains(&value))
}

fn part1(fields: &[Field], tickets: &[Ticket]) {
    let mut valid: Vec<bool> = vec![false; 1000];
    fields
        .iter()
        .flat_map(|field| &field.rules)
        .flat_map(|x| x.to_owned())
        .for_each(|v| valid[v] = true);
    let error_rate: usize = tickets
        .iter()
        .flat_map(|t| t.iter())
        .filter(|v| !valid[**v])
        .sum();
    println!("Ticket scanning error rate: {}", error_rate);
}

fn part2(fields: &Vec<Field>, my_ticket: &Ticket, nearby_tickets: &Vec<Ticket>) {
    let mut valid: Vec<bool> = vec![false; 1000];
    fields
        .iter()
        .flat_map(|field| &field.rules)
        .flat_map(|x| x.to_owned())
        .for_each(|v| valid[v] = true);
    let k = std::iter::once(my_ticket)
        .chain(nearby_tickets)
        .filter(|ticket| ticket.iter().all(|val| valid[*val]))
        .flat_map(|ticket| ticket.iter().enumerate())
        .sorted()
        .group_by(|x| x.0)
        .into_iter()
        .map(|(_index, group)| {
            let mut possible_fields: HashSet<&Field> = fields.iter().collect();
            for (_, val) in group {
                for field in possible_fields.to_owned() {
                    if !within_constraints(field, *val) {
                        possible_fields.remove(field);
                    }
                }
            }
            possible_fields
        })
        .collect_vec();
    let mut used_fields: HashSet<&Field> = HashSet::new();
    let sorted_iterator = k.iter().enumerate().sorted_by_key(|(_i, s)| s.len());
    let mut res = 1;
    for (field_index, possible_fields) in sorted_iterator {
        let (field,) = possible_fields
            .difference(&used_fields)
            .copied()
            .collect_tuple()
            .unwrap();
        used_fields.insert(&field);
        if field.name.starts_with("departure") {
            res *= my_ticket[field_index];
        }
        println!("field {} is {}", field_index, field);
    }
    println!("Result is {}", res);
}

pub fn main() {
    let (fields, my_ticket, nearby_tickets) = read_input();
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1(&fields, &nearby_tickets),
        Some(p) if p == "part2" => part2(&fields, &my_ticket, &nearby_tickets),
        _ => println!("Please specify a part (part1 | part2)"),
    }
}
