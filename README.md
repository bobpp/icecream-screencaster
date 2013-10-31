# Icecream Screen-caster

## Setup guide

### 1. Install LiveReload Extension

SEE: https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei

And Avaliable "ファイルのURLアクセスを許可する" on Chrome Extension Administration page (chrome://extensions/)

### 2. Setup Perl by plenv / Ruby by rbenv

SEE: https://github.com/tokuhirom/plenv

SEE: https://github.com/sstephenson/rbenv

or if you use Homebrew

```bash
$ brew install plenv perl-build rbenv ruby-build
```

### 3. Build Perl / Ruby

```bash
$ rbenv install ...
$ rbenv global ...
$ rbenv rehash

$ plenv install ...
$ plenv global ...
$ plenv rehash
```

### 4. Setup Carton / Bundle

```bash
$ plenv install-cpanm
$ plenv rehash
$ cpanm Carton

$ gem install bundle
$ rbenv rehash
```

### 5. Require Module install by Carton / Bundle

```bash
$ cd /path/to/this/repos
$ carton install
$ bundle install --path vendor/bundle
```

### 6. Start Guard-LiveReload

```bash
$ bundle exec guard
```

### 7. Make ScreenCast html

```bash
$ carton exec perl screen-caster.pl <TWEET-ID>
```

Auto reload screen.html
