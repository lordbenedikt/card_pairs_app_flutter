use std::env;
use std::fs;
use std::io::BufWriter;
use std::io::{BufRead, BufReader, Write};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Directory path of the .assets/images folder
    let assets_dir = "./../assets/images";

    // Rename files in the directory to meet the criteria
    rename_files_in_directory(&assets_dir)?;

    // Read all file names from the directory
    let entries = fs::read_dir(assets_dir)?;

    // Create an array of strings with relative paths
    let asset_paths: Vec<String> = entries
        .filter_map(|entry| {
            if let Ok(entry) = entry {
                if let Ok(file_name) = entry.file_name().into_string() {
                    Some(format!("    - assets/images/{}", file_name))
                } else {
                    None
                }
            } else {
                None
            }
        })
        .collect();

    // Read the pubspec.yaml file
    let pubspec_path = "pubspec.yaml";
    let pubspec_file = fs::File::open(&pubspec_path)?;
    let reader = BufReader::new(pubspec_file);
    let mut in_flutter_section = false;
    let mut in_assets_section = false;

    // Create a temporary file for writing
    let temp_pubspec_path = "pubspec_temp.yaml";
    let temp_pubspec_file = fs::File::create(&temp_pubspec_path)?;

    let mut temp_pubspec = BufWriter::new(temp_pubspec_file);

    for line in reader.lines() {
        let line = line?;

        if in_assets_section {
            if line.trim().starts_with('-') {
                // Skip the existing asset paths
                continue;
            }
            in_assets_section = false;
        }
        if in_flutter_section {
            if line.trim() == "assets:" {
                in_assets_section = true;
                writeln!(temp_pubspec, "{}", &line)?;
                for asset_path in &asset_paths {
                    writeln!(temp_pubspec, "{}", asset_path)?;
                }
            } else {
                writeln!(temp_pubspec, "{}", &line)?;
            }
        } else {
            writeln!(temp_pubspec, "{}", &line)?;
            if line.trim() == "flutter:" {
                in_flutter_section = true;
            }
        }
    }

    // If assets were not found within the flutter section, add it
    if !in_assets_section {
        writeln!(temp_pubspec, "  assets:")?;
        for asset_path in &asset_paths {
            writeln!(temp_pubspec, "{}", asset_path)?;
        }
    }

    // Close and rename the temporary file to replace the original
    fs::rename(temp_pubspec_path, pubspec_path)?;

    Ok(())
}

fn rename_files_in_directory(directory_path: &str) -> Result<(), Box<dyn std::error::Error>> {
    let entries = fs::read_dir(directory_path)?;

    for entry in entries {
        if let Ok(entry) = entry {
            let path = entry.path();
            let file_name = path.file_name().and_then(|s| s.to_str()).unwrap_or("");
            let new_name = sanitize_filename(file_name);
            let new_path = path.with_file_name(new_name);
            fs::rename(path, new_path)?;
        }
    }

    Ok(())
}

fn sanitize_filename(filename: &str) -> String {
    let sanitized = filename
        .chars()
        .map(|c| if c == ' ' { '_' } else { c })
        .filter(|c| c.is_alphanumeric() || *c == '_' || *c == '.')
        .collect();
    sanitized
}
