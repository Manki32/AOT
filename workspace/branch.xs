// This is the original branch.
branch v1 {
  color = "#fff3cd"
  middleware = {
    function: {pre: [], post: []}
    query   : {pre: [], post: []}
    task    : {pre: [], post: []}
    tool    : {pre: [], post: []}
  }

  history = {
    function  : 100
    query     : 100
    task      : 100
    tool      : 100
    trigger   : 100
    middleware: false
  }
}