#!/usr/bin/env bash

# ++-----------------+
# || Variables       |
# ++-----------------+

export STEP_ASSETS="${SCENARIO_OUTPUT_FOLDER}conf/"

# ++-----------------+
# || Begin           |
# ++-----------------+

header2 "Define Consul services for HashiCups"

# export NODES_ARRAY=( "hashicups-db" "hashicups-api" "hashicups-frontend" "hashicups-nginx" )
NODES_ARRAY=( "hashicups-db" "hashicups-api" "hashicups-frontend" "hashicups-nginx" )

for node in "${NODES_ARRAY[@]}"; do

  ## Checking the number of configured instances for the scenario.
  NUM="${node/-/_}""_NUMBER"

  if [ "${!NUM}" -gt 0 ]; then
    
    header3 "Define Consul Service for ${node}"
    
    log "Found ${!NUM} instances of ${node}"

    for i in `seq ${!NUM}`; do

      export NODE_NAME="${node}-$((i-1))"

      ## Create folder to contain configuration for the service instance
      mkdir -p "${STEP_ASSETS}${NODE_NAME}"

      consul acl token create -description="SVC ${node} token" --format json -service-identity="${node}" > ${STEP_ASSETS}secrets/acl-token-svc-${NODE_NAME}.json

      export CONSUL_AGENT_TOKEN=`cat ${STEP_ASSETS}secrets/acl-token-svc-${NODE_NAME}.json | jq -r ".SecretID"`

      ## Adds a tag to the service instance `inst_0` to identify it in Consul
      export SVC_TAGS="\"inst_$((i-1))\""

      ## [cmd] [script] generate_hashicups_service_config.sh
      log -l WARN -t '[SCRIPT]' "Generate HashiCups service config"
      execute_supporting_script "generate_hashicups_service_config.sh"
    done

  else
    log_warn "No instance found for ${node}. Leaving unconfigured."
  fi   

done




