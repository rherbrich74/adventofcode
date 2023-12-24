// Solution for day 1 puzzle from adventofcode.com
// 
// 2023 written by Ralf Herbrich
// Hasso Plattner Institute, Potsdam, Germany

use std::fs::File;
use std::io::BufReader;
use std::io::BufRead;

// solution for the first part of the puzzle
fn part1() {
    // read a file named "input.txt" line by line 
    let file = File::open("input.txt").unwrap();
    let reader = BufReader::new(file);

    let mut sum = 0;

    // read the file f line by line into input
    for l in reader.lines() {
        let str = l.unwrap();

        let mut first = 0;
        let mut last = 0;

        for c in str.chars() {
            if c >= '0' && c <= '9' {
                first = char::to_digit(c, 10).unwrap();
                break;
            }
        }
        for c in str.chars().rev() {
            if c >= '0' && c <= '9' {
                last = char::to_digit(c, 10).unwrap();
                break;
            }
        }

        sum += first*10 + last;
    }

    println!("sum: {}", sum);
}

// solution for the second part of the puzzle
fn part2() {
    const PATTERNS : [(&str, u32); 20] = [("0", 0),
    ("1", 1),
    ("2", 2),
    ("3", 3),
    ("4", 4),
    ("5", 5),
    ("6", 6),
    ("7", 7),
    ("8", 8),
    ("9", 9),
    ("zero", 0),
    ("one", 1),
    ("two", 2),
    ("three", 3),
    ("four", 4),
    ("five", 5),
    ("six", 6),
    ("seven", 7),
    ("eight", 8),
    ("nine", 9)];

    const PATTERNS_REV : [(&str, u32); 20] = [("0", 0),
    ("1", 1),
    ("2", 2),
    ("3", 3),
    ("4", 4),
    ("5", 5),
    ("6", 6),
    ("7", 7),
    ("8", 8),
    ("9", 9),
    ("orez", 0),
    ("eno", 1),
    ("owt", 2),
    ("eerht", 3),
    ("ruof", 4),
    ("evif", 5),
    ("xis", 6),
    ("neves", 7),
    ("thgie", 8),
    ("enin", 9)];

    // read a file named "input.txt" line by line 
    let file = File::open("input.txt").unwrap();
    let reader = BufReader::new(file);

    let mut sum = 0;

    // read the file f line by line into input
    for l in reader.lines() {
        let str = l.unwrap();

        let mut first = 0;
        let mut last = 0;

        'outer: for (i, _) in str.chars().enumerate() {
            for p in PATTERNS.iter() {
                if i+p.0.len() <= str.len() && p.0 == str[i..i+p.0.len()].to_string() {
                    first = p.1;
                    break 'outer;
                }
            }
        }
        
        let rev_str = str.chars().rev().collect::<String>();
        'outer2: for (i, _) in rev_str.chars().enumerate() {
            for p in PATTERNS_REV.iter() {
                if i+p.0.len() <= rev_str.len() && p.0 == rev_str[i..i+p.0.len()].to_string() {
                    last = p.1;
                    break 'outer2;
                }
            }
        }

        sum += first*10 + last;
    }

    println!("sum: {}", sum);
}


fn main() {
    part1();
    part2();
}
