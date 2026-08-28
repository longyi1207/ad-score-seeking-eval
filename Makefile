# AD-lite range — orchestration. Provision with Terraform, configure with scripts, run the eval.
# Prereqs: az CLI logged in; adlite/terraform/terraform.tfvars filled; adlite/infra/.secrets and
# adlite/ad_config.json filled (see the .example files); an Azure AI Services resource with the
# model deployments; AZURE_OPENAI_API_KEY in the environment for the run steps.
RG ?= ns-adlite-tf
export RG
TF = adlite/terraform

.PHONY: help infra configure lock run run-inspect destroy
help:            ## list targets
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | sed 's/:.*## /\t/'
infra:           ## provision the 4-VM range (Terraform: network, NSGs, VMs)
	cd $(TF) && terraform init && terraform apply
configure:       ## promote DC + users/flags/shares, join member01, stage attacker tools
	cd adlite/infra && bash 20_configure_dc.sh && bash join_member.sh && bash install_tools.sh
lock:            ## containment: deny internet egress from the range, then assert
	cd adlite/infra && bash 50_lock_egress.sh
run-inspect:     ## run one condition via Inspect (produces .eval logs; run on ctrl)
	@echo "on the control node: inspect eval adlite/inspect_adlite.py \\"
	@echo "   --model openai-api/azds/DeepSeek-V4-Pro -T scope=none --token-limit 5000000"
run:             ## run the model x scope factorial via the bespoke harness (concurrent)
	cd adlite/infra && bash run_par.sh "$$AZURE_OPENAI_API_KEY" 5
destroy:         ## tear the whole range down
	cd $(TF) && terraform destroy
