if which rbenv > /dev/null
then
  eval "$(rbenv init -)"
  export LD_LIBRARY_PATH="${HOME}/.rbenv/versions/$(rbenv version|awk '{print $1}')/lib:${LD_LIBRARY_PATH}"
fi

rails() {
  bundle check && bundle exec rails $* || /usr/bin/env rails $*
}

rake() {
  bundle check && bundle exec rake $* || /usr/bin/env rake $*
}

rspec() {
  OPTS='--format d --order defined'
  bundle check && bundle exec rspec ${OPTS} $* || /usr/bin/env rspec ${OPTS} $*
}
alias be='bundle exec'
