source <(kubectl completion zsh)

alias k=kubectl
complete -o default -F __start_kubectl k

# get all running pods in namespace
alias kgrp="kubectl get pods --field-selector=status.phase=Running"