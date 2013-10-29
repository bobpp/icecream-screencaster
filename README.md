# Icecream Screen-caster

## Setup guide

### 1. Install LiveReload Extension

SEE: https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei

And Avaliable "ファイルのURLアクセスを許可する" on Chrome Extension Administration page (chrome://extensions/)

### 2. Setup Perl by plenv / Ruby by rbenv

SEE: https://github.com/tokuhirom/plenv

SEE: https://github.com/sstephenson/rbenv

### 3. Setup Carton / Bundle

```bash
$ plenv install-cpanm
$ plenv rehash
$ cpanm Carton

$ gem install bundle
$ rbenv rehash
```

### 4. Require Module install by Carton / Bundle

```bash
$ cd /path/to/this/repos
$ carton install
$ bundle install --path vendor/bundle
```

### 5. Start Guard-LiveReload

```bash
$ bundle exec guard
```

### 6. Make ScreenCast html

```bash
$ carton exec perl screen-caster.pl <TWEET-URL>
```

Auto reload screen.html
