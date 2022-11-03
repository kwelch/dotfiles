echo "source <(kubectl completion bash)"

alias k=kubectl
complete -o default -F __start_kubectl k

# get all running pods in namespace
alias kgrp=kubectl get pods --field-selector=status.phase=Running