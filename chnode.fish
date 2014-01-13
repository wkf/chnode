set CHNODE_VERSION '0.0.1'

set -eg NODES
test -d "/usr/local/Cellar/node/"; and set -xg NODES $NODES /usr/local/Cellar/node/*
test -d "$HOME/.nodes/";           and set -xg NODES $NODES "$HOME"/.nodes/*

function chnode_reset
  test -z "$NODE_ROOT"; and return

  for path in $PATH
    test "$path" = "$NODE_ROOT/bin"; or set -g NEW_PATH $NEW_PATH $path
  end

  set PATH $NEW_PATH
  set -eg NEW_PATH

  set -e NODE_ROOT
  return 0
end

function chnode_use
  echo $argv | read -l node_path opts

  if not test -x "$node_path/bin/node"
    echo "not executable: $node_path/bin/node" >&2
    return 1
  end

  test -n "$NODE_ROOT"; and chnode_reset

  set -gx NODE_ROOT $node_path
  set PATH $NODE_ROOT/bin $PATH
  set -gx NODE_VERSION (eval "$NODE_ROOT/bin/node -v | cut -c 2-")
end

function chnode
  if test "$argv" = ""
    for node in $NODES
      test "$node" = "$NODE_ROOT"; and set star '*'; or set star ' '
      set node (basename $node); echo " $star$node"
     end
     return 0
  end

  switch $argv[1]
    case '-h' '--help'
      echo "usage: chnode [VERSION|system]"
    case '-v' '--version'
      echo "$CHNODE_VERSION"
    case 'system'
      chnode_reset
    case '*'
      echo $argv | read -l node_version

      set -l match ''

      for node in $NODES
        switch (basename $node)
          case "*$node_version*"
            set match "$node"
        end
      end

      if test -z "$match"
        echo "unknown version: $node_version" >&2
        return 1
      end

      chnode_use "$match" "$opts"
  end
end

