var CommentBox = React.createClass({
  loadCommentsFromServer: function() {
    $.ajax({
      url: this.props.url,
      dataType: 'json',
      cache: false,
      success: function(data) {
        this.setState({data: data.info});
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },
  getInitialState: function() {
    return {data: []};
  },
  componentDidMount: function() {
    this.loadCommentsFromServer();
    setInterval(this.loadCommentsFromServer, this.props.pollInterval);
  },
  render: function() {
    return (
      <div className="commentBox">
        <CommentList data={this.state.data} />
      </div>
    );
  }
});

var CommentList = React.createClass({
  render: function() {
    var infoNodes = this.props.data.map(function (info) {
      return (
        <Comment info={info} />
      );
    });
    return (
      <div className="infoList">
        {infoNodes}
      </div>
    );
  }
});

var Comment = React.createClass({
  render: function() {
    return (
      <div className="info">
        <h2 className="name">
          {this.props.info.name}
        </h2>
        <div>
          {this.props.info.date}
        </div>
        <div>
          {this.props.info.status}
        </div>
        <div>
          {this.props.info.message}
        </div>
        {this.props.children}
      </div>
    );
  }
});

ReactDOM.render(
  <CommentBox url="/api/traininfo" pollInterval={300000} />,
  document.getElementById('content')
);
