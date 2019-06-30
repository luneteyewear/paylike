workflow "Tests" {
  on = "push"
  resolves = [
    "Runs tests on Ruby 2.6",
  ]
}

action "Runs tests on Ruby 2.6" {
  uses = "docker://ruby:2.6-alpine"
  args = [
    "sh", "-c",
    "apk add -U git build-base && bundle install && rake"
  ]
}
