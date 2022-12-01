pub fn run(part1_fn: impl Fn() -> (), part2_fn: impl Fn() -> ()) {
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1_fn(),
        Some(p) if p == "part2" => part2_fn(),
        _ => eprintln!("Please specify a part (part1 | part2)"),
    }
}
