// ローディング用コンポーネント
var Loader = React.createClass({
  render: function() {
    //loadingプロパティにより処理分け
    if (this.props.isActive) {
      return (
        //ローディングアイコン
        <i className="fa fa-refresh fa-spin fa-5x"></i>
      );
    } else {
      return null;
    }
  }
});

var CommentBox = React.createClass({
  loadCommentsFromServer: function() {
    $.ajax({
      url: this.props.url,
      dataType: 'json',
      cache: false,
      success: function(data) {
        this.setState({
          loading: false,
          data: data.info
        });
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },
  getInitialState: function() {
    return {
      loading: true,
      data: [
        {
          index: 0,
          name: '',
          date: '',
          status: '',
          message: ''
        }
      ]
    };
  },
  componentDidMount: function() {
    this.loadCommentsFromServer();
    setInterval(this.loadCommentsFromServer, this.props.pollInterval);
  },
  render: function() {
    return (
      <div className="commentBox">
        <Loader isActive={this.state.loading} />
        <CommentList data={this.state.data} />
      </div>
    );
  }
});

var CommentList = React.createClass({
  getInitialState() {
    return {
      count: 0
    };
  },
  nextInfo() {
    this.setState({ count: (this.state.count + 1) % this.props.data.length});
    this.setState({ target: [this.props.data[this.state.count]]});
  },
  componentDidMount: function() {
    this.nextInfo();
    setInterval(this.nextInfo, 10000);
  },
  render: function() {
    var infoNodes = [];
    var index = this.state.count;
    this.props.data.forEach(function (info) {
      if (info.index == index) {
        infoNodes.push(<Comment info={info} />);
      }
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
