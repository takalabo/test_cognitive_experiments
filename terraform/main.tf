terraform {
  required_version = "~> 1.10.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws" # ライブラリのimport元指定
      version = "~> 5.0" # バージョン指定
    }
  }
  cloud {
    organization = "takalabo"
    
    workspaces {
      name = "test_cognitive_experiments"
    }
  }
}

provider aws {
  region = "ap-northeast-1" # リージョンの指定
}
