// Solution for day 2 puzzle from adventofcode.com
//
// 2023 written by Ralf Herbrich
// Hasso Plattner Institute, Potsdam, Germany

use std::fs::File;
use std::io::BufRead;
use std::io::BufReader;

// solution for the first part of the puzzle
fn part1(filename: &str) {
    // read a file named "input.txt" line by line
    let reader = match File::open(filename) {
        Ok(file) => BufReader::new(file),
        Err(error) => panic!("Problem opening the file: {:?}", error),
    };

    // read the file f line by line into input
    let sum: u32 = reader.lines()
        .map(|l| {
            let str = l.unwrap();
            let cards = str
                .split(':')
                .collect::<Vec<&str>>()[1]
                .split('|')
                .collect::<Vec<&str>>();

            let winning_cards = cards[0]
                .split_ascii_whitespace()
                .map(|x| x.parse::<u32>().unwrap())
                .collect::<Vec<u32>>();
            
            let no_matches = cards[1]
                .split_ascii_whitespace()
                .map(|x| { 
                    if winning_cards.contains(&x.parse::<u32>().unwrap()) {
                        1
                    } else {
                        0
                    }
                })
                .sum::<u32>();

            if no_matches == 0 {
                0
            } else {
                1<<(no_matches - 1)
            }
        })
        .sum();

    println!("sum: {}", sum);
}

fn main() {
    part1("input.txt");
}
