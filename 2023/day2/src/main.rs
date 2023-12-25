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

            let s: Vec<&str> = str.split(':').collect();
            let game_no = s[0].split(' ')
                .collect::<Vec<&str>>()[1]
                .parse::<u32>()
                .unwrap();

            let has_problem = s[1].split(';')
                .map(|set| {
                    set.trim()
                        .split(',')
                        .map(|dice| {
                            let d = dice.trim().split(' ').collect::<Vec<&str>>();
                            match d[1] {
                                "red" =>  (d[0].parse::<u32>().unwrap(), 0, 0),
                                "green" => (0, d[0].parse::<u32>().unwrap(), 0),
                                "blue" => (0, 0, d[0].parse::<u32>().unwrap()),
                                _ => panic!("unknown color"),
                            }
                        })
                        .fold((0, 0, 0), |acc, x| {
                            (acc.0 + x.0, acc.1 + x.1, acc.2 + x.2)
                        })
                })
                .any(|(red, green, blue)| red > 12 || green > 13 || blue > 14);

            if has_problem {
                None
            } else {
                Some(game_no)
            } 
        })
        .filter(|x| x.is_some())
        .map(|x| x.unwrap())
        .sum();

    println!("sum: {}", sum);
}

fn main() {
    part1("input.txt");
}
