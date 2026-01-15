# 1. Goal
the goal of this project is to load and fix issues from github repo

# 2.steps

You are giving a json file with one line, which represents a pr data from a github repo, your role is a professional software engineer, you should read the pr data and fix the issue.

follow the steps below:
    0. MUST DO: check the patches folder, if the patch <org>_<repo>_<pr_number>.diff or <org>__<repo>__<pr_number>.diff already exists, skip this line
    1. extract and analyze the pr body and title
    2. extract and analyze the related issues if exists
    3. find the base commit hash for this PR ("sha" property)
    4. if the repo is not cloned, clone the repo under the repos folder and remove other repo folders
    5. rebase to the commit hash in step 3
    6. fix or refactor the code following the pr description
    7. add tests for your fix
    8. verify your fix, make sure your fix is correct
    9. generate the git patch in diff format and save it to ./patches/ folder, the file name MUST BE <org>_<repo>_<pr_number>.diff
    10. copy semgrep_scan.sh and analyze_patch.sh to repo root dir
        10.1 run semgrep_scan.sh <org>_<repo>_<pr_number>.diff <org>_<repo>_<pr_number>_tmp.json
        10.2 run analyze_patch.sh <org>_<repo>_<pr_number>_tmp.json to get the score and grade
        10.3 append it to patch_scores.csv file with patch file name, score, grade
        
    11. extract the origin patch from pr and save to ./origin_patches with <org>_<repo>_<pr_number>.diff name

