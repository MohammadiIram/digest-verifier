name: Periodic Digest verifier

on:
  schedule:
    - cron: '*/2 * * * *'
  workflow_dispatch:
   inputs:
      branch_name:
        description: 'Branch Name to Run the Script On'
        required: true
        default: 'main'

# Job 
jobs:
  run-script:
    runs-on: ubuntu-latest

    # Steps
    steps:
    - uses: actions/checkout@v3

    - name: Execute sha_update.sh
      run: |
        chmod +x ./Periodic_digest_verifier.sh
        ./Periodic_digest_verifier.sh
