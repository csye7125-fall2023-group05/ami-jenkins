#!/bin/bash
sid="sid"
rishab="rishab"
karan="karan"
AMI_USERS="[\"${sid}\", \"${rishab}\", \"${karan}\"]"

echo $AMI_USERS

# - name: Create list of AMI users
#   run: |
#     sid=${{ secrets.SID }}
#     rishab=${{ secrets.RISHAB }}
#     karan=${{ secrets.KARAN }}
#     AMI_USERS="[${sid}, ${rishab}, ${karan}]"

# echo ami_users=${AMI_USERS} >> ami.pkrvars.hcl
