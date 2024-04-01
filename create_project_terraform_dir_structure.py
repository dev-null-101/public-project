#!/bin/env /bin/python3
"""Module creating project for terraform directory structure.
   Best directory structure based on Hashicorp. """

import os

project_name = input("Project name: " )
# get the script name
script_name = os.path.splitext(os.path.basename(__file__))[0]

def create_directory_structure():
    """Specify the main directory name"""
    # main_directory = "my_project"
    main_directory = project_name

    # Create the main directory
    os.makedirs(main_directory, exist_ok=True)

    # Add some files to the main directory
    file_names = [
        "provider.tf", 
        "version.tf", 
        "backend.tf", 
        "main.tf", 
        "variables.tf", 
        "terraform.tfvars", 
        "output.tf"
    ]

    for file_name in file_names:
        file_path = os.path.join(main_directory, file_name)
        # with open(file_path, "w", encoding="utf-8") as file:
        with open(file_path, "w", encoding="utf-8") as file:
            # file.write("This is content for {}.".format(file_name))
            # file.write(f"This is content for {file_name}")
            file.write(f"# Generated by {script_name}.py\n")
            # pass

    # Create a subdirectory within the main directory
    # subdirectory_name = "subdir"
    # subdirectory_path = os.path.join(main_directory, subdirectory_name)
    # os.makedirs(subdirectory_path, exist_ok=True)

    subdirectory_names = [
        "modules",
        "scripts",
        "files",
        "templates",
        "network_sample"
    ]

    for subdirectory_name in subdirectory_names:
        subdirectory_path = os.path.join(main_directory, subdirectory_name)
        os.makedirs(subdirectory_path, exist_ok=True)
        
    # create sample tf files and directories under sample directory
    sample_subdirectory_path = os.path.join(main_directory, "network_sample")
    sample_file_names = [
        "provider.tf", 
        "vpc.tf", 
        "loadbalancer.tf", 
        "variables.tf", 
        "variables-local.tf",  
        "output.tf",
        "README.md"
    ]

    sample_subdirectory_names = [
        "example",
        "docs"
    ]

    for sample_file_name in sample_file_names:
        sample_file_path = os.path.join(sample_subdirectory_path, sample_file_name)
        with open(sample_file_path, "w", encoding="utf-8") as file:
            file.write(f"# Generated by {script_name}.py\n")

    for sample_subdirectory_name in sample_subdirectory_names:
        sample_subdirectory_path = os.path.join(sample_subdirectory_path, sample_subdirectory_name)
        os.makedirs(sample_subdirectory_path, exist_ok=True)

    # dir_list_after = os.listdir(main_directory)  # List directories/files after creation

    print("Directory structure created successfully!")
    # print(dir_list_after)

if __name__ == "__main__":
    create_directory_structure()
