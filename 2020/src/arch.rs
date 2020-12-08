use itertools::Itertools;

#[derive(Clone, Debug)]
pub enum Instr {
    Nop(isize),
    Acc(isize),
    Jmp(isize)
}

type State = isize;

pub type Program = Vec<Instr>;

pub fn parse_instruction(raw_instr: &str) -> Instr {
    let (opcode, arg) = raw_instr.split_whitespace().collect_tuple().unwrap();
    match opcode {
        "nop" => Instr::Nop(arg.parse().expect("Invalid arg")),
        "acc" => Instr::Acc(arg.parse().expect("Invalid arg")),
        "jmp" => Instr::Jmp(arg.parse().expect("Invalid arg")),
        instr => panic!(format!("Unimplemented instruction {}", instr))
    }
}

pub fn parse_program(source: &str) -> Program {
    source.lines().map(parse_instruction).collect()
}

pub mod interpreter {
    use std::iter;

    use super::Instr;
    use super::Program;
    use super::State;

    pub fn step_through(program: &Program, start: usize) -> impl Iterator<Item = (State, Instr, usize, isize)> + '_ {
        let mut visited: Vec<bool> = vec![false; program.len()];
        let mut iptr: isize = start as isize;
        let mut state: State = 0;
        iter::from_fn(move || {
            if iptr < 0 || iptr as usize >= program.len() { return None; }
            if visited[iptr as usize] { return None; }
            let prev = iptr as usize;
            visited[prev] = true;
            match program[prev] {
                Instr::Nop(_n) => {
                    iptr += 1;
                },
                Instr::Acc(n) => {
                    state += n;
                    iptr += 1;
                },
                Instr::Jmp(n) => {
                    iptr += n;
                }
            }
            Some((state, program[prev].to_owned(), prev, iptr))
        })
    }
}
