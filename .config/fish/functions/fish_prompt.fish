function fish_prompt --description 'Write out the prompt'
    eval /bin/powerline-go -hostname-only-if-ssh -error $status -jobs (count (jobs -p))
end
