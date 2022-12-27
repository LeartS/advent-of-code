use aoc2022;

fn to_decimal(snafu: &str) -> isize {
    snafu.chars().rev().enumerate().fold(0, |n, (i, c)| {
        let mul = 5_isize.pow(i as u32);
        match c {
            '2' => n + mul * 2,
            '1' => n + mul,
            '0' => n,
            '-' => n - mul,
            '=' => n - mul * 2,
            _ => panic!("Invalid SNAFU digit"),
        }
    })
}

fn to_snafu(n: isize) -> String {
    let mut m = n;
    let mut snafu = String::new();
    while m > 0 {
        let (snafu_digit, remainder) = match m % 5 {
            0 => ('0', 0),
            1 => ('1', 0),
            2 => ('2', 0),
            3 => ('=', 2),
            4 => ('-', 1),
            _ => panic!("The modulo operator doesn't work.."),
        };
        snafu.push(snafu_digit);
        m = (m + remainder) / 5;
    }
    snafu.chars().rev().collect()
}

fn part1() {
    let res: isize = aoc2022::io::iterate_lines()
        .map(|line| to_decimal(line.trim().as_ref()))
        .sum();
    println!("Sum is {}, in SNAFU: {}", res, to_snafu(res));
}

fn part2() {
    todo!();
}

pub fn main() {
    aoc2022::cli::run(part1, part2);
}
