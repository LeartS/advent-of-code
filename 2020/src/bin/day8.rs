use std::io::{self, Read};

use aoc2020::arch::*;

fn part1(program: &Program) {
    let (res, ..) = interpreter::step_through(program, 0).into_iter().last().unwrap();
    println!("Value of accumulator before loop: {}", res)
}

fn part2(program: &Program) {
    let mut terminates: Vec<bool> = vec![false; program.len()];
    for (index, _) in program.iter().enumerate() {
        let run: Vec<_> = interpreter::step_through(program, index).into_iter().collect();
        let (.., next_ptr) = run.last().unwrap();
        let does_terminate = *next_ptr < 0 || *next_ptr as usize >= program.len();
        for (_, _, iptr, _) in run.iter() {
            terminates[*iptr] = does_terminate;
        }
    };
    let k = interpreter::step_through(program, 0).into_iter().find(|(_, instr, ptr, _)| {
        match *instr {
            Instr::Jmp(_n) => *terminates.get(ptr + 1).unwrap_or(&false),
            Instr::Nop(n) => *terminates.get(((*ptr) as isize + n) as usize).unwrap_or(&false),
            Instr::Acc(_) => false
        }
    }).unwrap();
    println!("In order to make program terminate, change instruction {:?}", k.2);
}

pub fn main() {
    let mut buf = String::new();
    io::stdin().read_to_string(&mut buf).expect("Error reading input");
    let program = parse_program(&buf);
    match std::env::args().skip(1).next() {
        Some(p) if p == "part1" => part1(&program),
        Some(p) if p == "part2" => part2(&program),
        _ => println!("Please specify a part (part1 | part2)"),
    }
}
