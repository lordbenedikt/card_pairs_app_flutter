use image_compressor::Factor;
use image_compressor::FolderCompressor;
use std::fs;
use std::io::BufWriter;
use std::io::{BufRead, BufReader, Write};
use std::path::Path;
use std::path::PathBuf;
use std::sync::mpsc;

extern crate image;
extern crate image_compressor;

use image::GenericImageView;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Directory path of the .assets/images folder
    let original_images_dir = "../assets/images/original";
    let resized_images_dir = "../assets/images/resized";
    let compressed_images_dir = "../assets/images/compressed";

    // Rename files in the directory to meet the criteria
    rename_files_in_directory(&original_images_dir)?;

    // Read all file names from the directory, change extension to 'jpg'
    let new_file_names: Vec<String> = fs::read_dir(original_images_dir)?
        .filter_map(Result::ok)
        .filter(|entry| entry.path().extension().is_some_and(|ext| !ext.is_empty()))
        .map(|entry| {
            String::from(
                entry
                    .path()
                    .with_extension("jpg")
                    .file_name()
                    .unwrap()
                    .to_str()
                    .unwrap(),
            )
        })
        .collect();
    // resize images
    let source_paths: Vec<PathBuf> = fs::read_dir(original_images_dir)?
        .filter_map(Result::ok)
        .filter(|entry| entry.path().extension().is_some_and(|ext| !ext.is_empty()))
        .map(|entry| entry.path())
        .collect();
    let dest_paths: Vec<String> = new_file_names
        .iter()
        .map(|file_name| format!("{}/{}", resized_images_dir, file_name))
        .collect();
    for (src, dest) in source_paths.iter().zip(dest_paths.iter()) {
        resize_image(src, dest);
    }

    // compress images
    compress_images(resized_images_dir, compressed_images_dir);

    // Create an array of strings with relative paths
    let pubspec_entries: Vec<String> = new_file_names
        .iter()
        .map(|file_name| format!("    - assets/images/resized/{}", file_name))
        .collect();

    // Read the pubspec.yaml file
    let pubspec_path = "../pubspec.yaml";
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
                for asset_path in &pubspec_entries {
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
        for asset_path in &pubspec_entries {
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

fn resize_image<O, D>(src_path: O, dest_path: D)
where
    O: AsRef<Path>,
    D: AsRef<Path>,
{
    println!(
        "resized image from source: {:?}\nto destination: {:?}",
        src_path.as_ref(),
        dest_path.as_ref()
    );
    let image = image::open(src_path).unwrap();
    let (width, height) = image.dimensions();

    let min_width = 300;
    let min_height = 300;

    // Calculate new dimensions while maintaining the aspect ratio
    let (new_width, new_height) = if width < min_width && height < min_height {
        (width, height) // Do not resize if smaller than the minimum
    } else if width > height {
        (min_width, min_width * height / width)
    } else {
        (min_height * width / height, min_height)
    };

    // Resize the image
    let resized_image = image.thumbnail(new_width, new_height);

    // Save the resized image to the temporary directory
    resized_image
        .save_with_format(
            dest_path.as_ref().with_extension("jpg"),
            image::ImageFormat::Jpeg,
        )
        .unwrap();
}

fn compress_images<O, D>(src_path: O, dest_path: D)
where
    O: AsRef<Path>,
    D: AsRef<Path>,
{
    // println!("{}, {}", src_path, dest_path);
    let thread_count = 4; // number of threads
    let (tx, _tr) = mpsc::channel(); // Sender and Receiver. for more info, check mpsc and message passing.

    let mut comp = FolderCompressor::new(src_path, dest_path);
    comp.set_factor(Factor::new(75., 1.0));
    comp.set_thread_count(thread_count);
    comp.set_sender(tx);

    match comp.compress() {
        Ok(_) => {}
        Err(e) => println!("Cannot compress the folder!: {}", e),
    }
}
