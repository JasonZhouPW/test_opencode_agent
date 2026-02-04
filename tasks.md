# 1. Goal
the goal of this project is to load and fix issues from github repo

# 2.steps

You are giving a json file with multiple lines(SKIP the hidden files,name started with "." or "._"), each line represents a pr data from a github repo, your role is a professional software engineer, you should read the pr data and fix the issue.
for each line:
  follow the steps below:
    0. MUST DO: check the patches folder, if the patch <org>_<repo>_<pr_number>.diff or <org>__<repo>__<pr_number>.diff already exists, skip this line
    1. extract and analyze the pr body and title
    2. extract and analyze the related issues if exists
    3. find the base commit hash for this PR ("base_commit_hash" or "bash_commit" property)
    4. if the repo is not cloned, clone the repo under the repos folder and remove other repo folders
    5. rebase to the commit hash in step 3
    6. run the tests in project if exists, records the failed tests records.
    7. give your solutions for the issue and fix or refactor the code following the pr description,DO NOT REFER to the origin "fix_patch" in the pr.
    8. run all the tests in the projects again if exists. if failed the failed number is greater than step 6, go back to step 7 ,max retry 10 times, if exceed the max retry, go to step 14.
    9. if the pr has "test_patch" field, extract the test patch and try to apply it.
    10. run the tests just applied, if failed, go back to step 7, ,max retry 10 times, if exceed the max retry, go to step 14.
    11. generate the git patch in diff format and save it to ./patches/ folder, the file name MUST BE <org>_<repo>_<pr_number>.diff
    12. copy semgrep_scan.sh and analyze_patch.sh to repo root dir
        12.1 run semgrep_scan.sh <org>_<repo>_<pr_number>.diff <org>_<repo>_<pr_number>_tmp.json
        12.2 run analyze_patch.sh <org>_<repo>_<pr_number>_tmp.json to get the score and grade
        12.3 append it to patch_scores.csv file with patch file name, score, grade
    13. extract the origin patch from pr and save to ./origin_patches folder, the file name MUST BE <org>_<repo>_<pr_number>.diff
    14. append the result in ./results.csv file with pr file name, patch file name, success (true/false), error message (if any)
    15. do next line

