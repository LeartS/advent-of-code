use std::io::{self, Read};
use itertools::Itertools;
use petgraph::algo::has_path_connecting;
use petgraph::graphmap::GraphMap;
use petgraph::Directed;

fn parse_rule(rule: &str) -> Vec<(&str, &str, usize)> {
    let (source, targets) = rule[..rule.len()-1].splitn(2, " contain ").collect_tuple().expect("Invalid rule");
    let (_, source) = source.rsplitn(2, ' ').collect_tuple().expect("Invalid rule");
    if targets == "no other bags" { return vec!(); }
    targets.split(", ").map(|t| {
        let (n, node) = t.splitn(2, ' ').collect_tuple().expect("Invalid rule");
        let (_, node) = node.rsplitn(2, ' ').collect_tuple().expect("Invalid rule");
        (source, node, n.parse().unwrap())

    }).collect_vec()
}

fn parse_rules(rules: &str) -> GraphMap<&str, usize, Directed> {
    let edges: Vec<(&str, &str, usize)> = rules.lines()
        .flat_map(parse_rule)
        .collect();
    GraphMap::from_edges(&edges)
}

fn part1(graph: &GraphMap<&str, usize, Directed>) {
    let count = graph.nodes()
        .filter(|&n| has_path_connecting(graph, n, "shiny gold".as_ref(), None))
        .count();
    println!("{:?} bag types can (transitively) contain shiny gold bags", count - 1);
}

fn count_contained_bags(graph: &GraphMap<&str, usize, Directed>, node_ref: &str) -> usize {
    graph.edges(node_ref).map(|(_outer, inner, count)| {
        count_contained_bags(graph, inner) * count + count
    }).sum::<usize>()
}

fn part2(graph: &GraphMap<&str, usize, Directed>) {
    let res = count_contained_bags(graph, "shiny gold");
    println!{"{} bags are required inside one shiny gold bag", res};
}

pub fn main() {
    let mut buf = String::new();
    io::stdin().read_to_string(&mut buf).expect("Error reading input");
    let g = parse_rules(buf.as_str());
    // Output the graph to `graphviz` `DOT` format
    // println!("{:?}", Dot::with_config(graph, &[]));
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1(&g),
        Some(p) if p == "part2" => part2(&g),
        _ => println!("Please specify a part (part1 | part2)"),
    }
}
