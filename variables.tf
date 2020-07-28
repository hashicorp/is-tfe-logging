variable "namespace" {
  description = "The name to prefix to resources to keep them unique."
  type        = string
  default     = "tfe-elk"
}

variable "vpc_cidr" {
  description = "CIDR block for PTFE AWS VPC. This is needed for the SG network access into the instance."
  type        = string
}

variable "vpc_id" {
  description = "Id of the VPC. This is needed for the SG network access into the instance."
  type        = string
}

variable "subnet_id" {
  description = "The subnet id to create the instance in."
  type        = string
}

variable "key_pair" {
  description = "AWS SSH key pair name to user for the instance."
  type        = string
}

variable "instance_type" {
  description = "The instance type/size to cretate."
  default     = "m5.large"
}

variable "associate_public_ip_address" {
  description = "If the ELK instance should have a public IP or not."
  type        = bool
  default     = false
}

variable "external_cidrs" {
  description = "List of CIDR ranges to allow traffic ingress into VPC."
  type        = list(string)
  default     = []
}

variable "tfe_elk_repo" {
  description = "The repo to clone on to the instance to run/configure ELK (i.e. THIS repo)."
  type        = string
  default     = "https://github.com/straubt1/tfe-elk.git"
}

variable "tfe_elk_branch" {
  description = "The branch of this repo to clone on to the instance to run/configure ELK."
  type        = string
  default     = "main"
}

variable "tags" {
  description = "Tags to apply to every resource"
  default     = {}
}
