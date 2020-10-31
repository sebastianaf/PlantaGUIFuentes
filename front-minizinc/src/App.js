import React from 'react';
import './App.css';
import axios from 'axios';

const backColor = {
  backgroundColor: 'Transparent',
};

class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      clients: 3,
      days: 7,
      centrals: 3,
      costs: [],
      capabilities: [],
      regimePercent: [],
      regimeDays: [],
      matrix: [],
      results: '',


      data: 'No hay informacion',
      dznfile: null

    }
    this.execute = this.execute.bind(this);
    this.onChangeClients = this.onChangeClients.bind(this);
    this.onChangeDays = this.onChangeDays.bind(this);
    this.onChangeCentrals = this.onChangeCentrals.bind(this);
    this.onChangeCosts = this.onChangeCosts.bind(this);
    this.onChangeCapabilities = this.onChangeCapabilities.bind(this);
    this.onChangeRegimePercent = this.onChangeRegimePercent.bind(this);
    this.onChangeRegimeDays = this.onChangeRegimeDays.bind(this);
    this.onCellChange = this.onCellChange.bind(this);
    this.onClickSubmit = this.onClickSubmit.bind(this);
  }

  componentDidMount() {
    this.setState({
      costs: new Array(this.state.centrals).fill(0),
      capabilities: new Array(this.state.centrals).fill(0),
      regimePercent: new Array(this.state.centrals).fill(0),
      regimeDays: new Array(this.state.centrals).fill(0),
      matrix: new Array(this.state.clients * this.state.days).fill(0)
    })
  }

  dznfile = (event) => {
    event.preventDefault();
    let file = event.target.files[0];
    this.setState({ 'dznfile': file })
    const reader = new FileReader();
    reader.onload = async (e) => {
      const text = reader.result;
      const inf = this.formatdata(text);
      console.log(inf);
      this.setState({ data: inf });
    };
    reader.readAsText(event.target.files[0]);

  }
  execute = () => {
    const data = new FormData();
    data.append('dznfile', this.state.data);
    axios({
      url: 'http://localhost:5000/dzn',
      method: 'POST',
      data: data,
      params: { model: 0 },
      config: { headers: { 'Content-Type': 'multipart/form-data' } }
    }).then((response) => {
      if (response.data === "") {
        alert("Se ha producido un error. Es posible que la causa sea la selección de un modelo incorrecto");
      } else {
        const result = response.data;
        this.setState({ results: result.substring(0, result.length - 22) });
      }
    }
    ).catch((error) => alert("Se ha producido un error. Es posible que la causa sea la selección de un modelo incorrecto"))


  }
  clean = (event) => {
    event.preventDefault();
    this.setState({ r: '', dznfile: null, model: -1, data: "No hay información" });
  }
  setModel = (data) => {
    this.setState({ model: data });
  }

  onChangeClients = (e) => {
    this.setState(
      {
        clients: e.target.value,
        matrix: new Array(e.target.value * this.state.days).fill(0)
      });
  }


  onChangeCentrals = (e) => {
    this.setState(
      {
        centrals: parseInt(e.target.value),
        costs: new Array(parseInt(e.target.value)).fill(0),
        capabilities: new Array(parseInt(e.target.value)).fill(0),
        regimeDays: new Array(parseInt(e.target.value)).fill(0),
        regimePercent: new Array(parseInt(e.target.value)).fill(0)
      });
      
  }

  onChangeDays = (e) => {
    this.setState(
      {
        days: e.target.value,
        matrix: new Array(this.state.clients * e.target.value).fill(0)
      });
  }

  onChangeCosts = (e) => {
    let newCosts = this.state.costs.slice()
    newCosts[e.target.id.substring(3, e.target.id.length)] = parseInt(e.target.value)
    this.setState({
      costs: newCosts
    })
    console.log(this.state.costs)
  }

  onChangeCapabilities = (e) => {
    let newCapabilities = this.state.capabilities.slice()
    newCapabilities[e.target.id.substring(3, e.target.id.length)] = parseInt(e.target.value)
    this.setState({
      capabilities: newCapabilities
    })
    console.log(this.state.capabilities)
  }

  onChangeRegimePercent = (e) => {
    let newRegimePercent = this.state.regimePercent.slice()
    newRegimePercent[e.target.id.substring(3, e.target.id.length)] = parseInt(e.target.value)
    this.setState({
      regimePercent: newRegimePercent
    })
    console.log(this.state.regimePercent)
  }

  onChangeRegimeDays = (e) => {
    let newRegimeDays = this.state.regimeDays.slice()
    newRegimeDays[e.target.id.substring(3, e.target.id.length)] = parseInt(e.target.value)
    this.setState({
      regimeDays: newRegimeDays
    })
    console.log(this.state.regimeDays)
  }

  onClickSubmit = () => {

    let demanda = '|'
    for (let i = 0; i < this.state.matrix.length; i++) {
      if ((i + 1) % this.state.days === 0) {
        demanda = (`${demanda}${this.state.matrix[i]}|`)
      } else {
        demanda = (`${demanda}${this.state.matrix[i]},`)
      }
    }

    let pre =
      `
    dias = ${this.state.days};
    clientes = ${this.state.clients};
    centrales = ${this.state.centrals};

    costos=[${this.state.costs}];
    capacidades=[${this.state.capabilities}];
    porcentajeRegimen=[${this.state.regimePercent}];
    diasRegimen=[${this.state.regimeDays}];

    demanda=[${demanda}]
    `
    this.setState({
      data: pre
    })
    console.log(`${this.state.data}`)

    this.execute();
  }

  onCellChange = (e) => {
    let newMatrix = this.state.matrix.slice()
    newMatrix[e.target.id.substring(3, e.target.id.length)] = parseInt(e.target.value)
    this.setState(
      {
        matrix: newMatrix
      }
    )
    //console.log(`${e.target.id.substring(3,e.target.id.length)}:${e.target.value}`)
    //console.log(this.state.matrix)
  }


  render() {

    var costs = [];
    for (let j = 0; j < this.state.centrals; j++) {
      costs.push(<input id={`cos${j}`} className="cell" type="number" min="0" value={this.state.costs[j]} onChange={this.onChangeCosts} />)
    }

    var capabilities = [];
    for (let j = 0; j < this.state.centrals; j++) {
      capabilities.push(<input id={`cap${j}`} className="cell" type="number" min="0" max="20" value={this.state.capabilities[j]} defaultValue={0} onChange={this.onChangeCapabilities} />)
    }

    var regimePercent = [];
    for (let j = 0; j < this.state.centrals; j++) {
      regimePercent.push(<input id={`rep${j}`} className="cell" type="number" min="0" max="20" defaultValue={0} value={this.state.regimePercent[j]} onChange={this.onChangeRegimePercent} />)
    }

    var regimeDays = [];
    for (let j = 0; j < this.state.centrals; j++) {
      regimeDays.push(<input id={`red${j}`} className="cell" type="number" min="0" max="20" defaultValue="0" value={this.state.regimeDays[j]} onChange={this.onChangeRegimeDays} />)
    }

    var consuptions = [];
    for (let i = 0; i < this.state.clients; i++) {
      for (let j = 0; j < this.state.days; j++) {
        consuptions.push(
          <input
            id={`con${j + (i * this.state.days)}`}
            value={this.state.matrix[j + (i * this.state.days)]}
            onChange={this.onCellChange}
            className="cell"
            type="number"
            min="0" max="20"
          />)
      }
      consuptions.push(<br />)
    }

    return (

      <div className="App" style={backColor}>

        <div className="main-container">

          <h1>Plantas de Energía</h1>
          <p>Por favor configure los parametros de entrada y los costos de cada cliente</p>



          <div className="header-titles" >
            <div>
              <label className="param-title" htmlFor="clients">Clientes</label>
              <input type="number" defaultValue={this.state.clients} id="clients" min="1" max="1000" onChange={this.onChangeClients} />
            </div>
            <div>
              <label className="param-title" htmlFor="days">Dias</label>
              <input type="number" defaultValue={this.state.days} id="days" min={1} max={31} onChange={this.onChangeDays} />
            </div>
            <div>
              <label className="param-title" htmlFor="days">Centrales</label>
              <input type="number" value={this.state.centrals} id="days" min={3} max={10} onChange={this.onChangeCentrals} />
            </div>
          </div>

          <div className="sub-params">
            <div className="sub-labels-left">
              <label className="param-title">Costos</label>
              <label className="param-title">Capacidades</label>
              <label className="param-title">Porcentajes de régimen</label>
              <label className="param-title">Días de régimen</label>
            </div>

            <div className="sub-labels-right">
              <div className="list">{costs}</div>
              <div className="list">{capabilities}</div>
              <div className="list">{regimePercent}</div>
              <div className="list">{regimeDays}</div>
            </div>
          </div>

          <div>
            <input id="submit" type="button" defaultValue={"Enviar datos"} onClick={this.onClickSubmit} />
          </div>


          <div className="matrix" >
            <div className="y-title">
              Clientes
            </div>
            <div className="elements">
              <div className="x-title">
                Dias
              </div>
              {consuptions}
            </div>
          </div>

          <div>
            <label htmlFor="results" >Resultados</label><br/>
            <textarea id="results" value={this.state.results} type="textarea" rows="10" cols="70" />
          </div>

          <br /><br />
        </div>
      </div>
    );
  }
}

export default App;
