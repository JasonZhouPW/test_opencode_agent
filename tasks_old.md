# 1. Goal
the goal of this project is to load and fix issues from github repo

# 2.steps

there are several raw dataset files in jsonl format under the ./raw_datasets/ folder, each line represents a pr data from a github repo, your role is a professional software engineer, you should read the pr data and fix the issue.

follow the steps below:

1. count the pr count (lines) in the data set file, remember don't miss any line
2. for each line
you should: 
    0. check the patches folder, if the patch <org>_<repo>_<pr_number>.diff or <org>__<repo>__<pr_number>.diff already exists, skip this line
    1. extract and analyze the pr body and title
    2. extract and analyze the related issues if exists
    3. find the base commit hash for this PR
    4. if the repo is not cloned, clone the repo under the repos folder and remove other repo folders
    5. rebase to the commit hash in step 3
    6. give a plan to fix the issue WITHOUT referring the pr diff
    7. fix or refactor the code following the plan
    8. add tests for your fix
    9. verify your fix
    10. generate the git patch in diff format and save it to ./patches/ folder, the file name should be <org>_<repo>_<pr_number>.diff
    11. extract the origin patch from pr and save to ./origin_patches with <org>_<repo>_<pr_number>.diff name
    12. process next line

