// Solution for day 1 puzzle from adventofcode.com
//
// 2023 written by Ralf Herbrich
// Hasso Plattner Institute, Potsdam, Germany

use std::fs::File;
use std::io::BufRead;
use std::io::BufReader;

// solution for the first part of the puzzle
fn part1() {
    // read a file named "input.txt" line by line
    let reader = match File::open("input.txt") {
        Ok(file) => BufReader::new(file),
        Err(error) => panic!("Problem opening the file: {:?}", error),
    };

    // read the file f line by line into input
    let sum : u32 = reader.lines()
        .map(|l| {
            let str = l.unwrap();

            let first = str.chars()
                .find(|c| c.is_ascii_digit())
                .unwrap()
                .to_digit(10)
                .unwrap();
            let last = str.chars()
                .rev()
                .find(|c| c.is_ascii_digit())
                .unwrap()
                .to_digit(10)
                .unwrap();
            first * 10 + last
        })
        .sum();

    println!("sum: {}", sum);
}

// solution for the second part of the puzzle
fn part2() {
    const PATTERNS: [(&str, u32); 20] = [
        ("0", 0), ("1", 1), ("2", 2), ("3", 3), ("4", 4), ("5", 5), ("6", 6), ("7", 7), ("8", 8), ("9", 9),
        ("zero", 0), ("one", 1), ("two", 2), ("three", 3), ("four", 4), ("five", 5), ("six", 6), ("seven", 7), ("eight", 8), ("nine", 9),
    ];

    // find the pattern in the string and return the corresponding number
    fn find_pattern(str: &str, i:usize, patterns: &[(&str, u32)]) -> Option<u32> {
        for p in patterns.iter() {
            if str[i..].starts_with(p.0) {
                return Some(p.1);
            }
        }
        None
    }

    // read a file named "input.txt" line by line
    let reader = match File::open("input.txt") {
        Ok(file) => BufReader::new(file),
        Err(error) => panic!("Problem opening the file: {:?}", error),
    };

    // read the file f line by line into input
    let sum : u32 = reader.lines()
        .map(|l| {
            let str = l.unwrap();

            let first = (0..str.len())
                .find_map(|i| find_pattern(&str, i, &PATTERNS))
                .unwrap();
            let last = (0..str.len())
                .rev()
                .find_map(|i| find_pattern(&str, i, &PATTERNS))
                .unwrap();
            first * 10 + last
        })
        .sum();

    println!("sum: {}", sum);
}

fn main() {
    part1();
    part2();
}
