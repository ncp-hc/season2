# Packer

NCP에 프로비저닝 수행하기 전에 미리 표준 이미지(골든 이미지)를 생성합니다.
반복적인 VM 프로비저닝과 Scale out 시 미리 준비된 이미지로 빠르게 확장할 수 있습니다.

각 구성요소의 설명은 다음과 같습니다.
- main.tf Terraform의 실행 프로바이더를 통해 ncp, packer를 구성하고 빌드하는 로직을 수행
- variable.tf Terraform 실행 시 변수에 대한 정의
- output.tf 타 Terraform Workspace에서 Remote state로 변수를 전달 받기 위해서, 해당 Workspace의 빌드 결과로 생성된 base image 이름을 출력
- main.pkr.hcl Packer 빌드에 대한 정의
- variable.pkr.hcl Packer 빌드 시 변수에 대한 정의