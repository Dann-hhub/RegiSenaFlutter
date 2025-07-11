import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faFilePdf, faComputer, faChartLine, faRightLong } from '@fortawesome/free-solid-svg-icons';
import Chart from 'react-apexcharts';
import './Dashboard.css';

const Dashboard = () => {
  // Datos para gráficos
  const ventasOptions = {
    chart: {
      id: 'ventas-chart',
      toolbar: {
        show: false
      }
    },
    xaxis: {
      categories: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun']
    },
    colors:['#22bc2b']
  };

  const ingresosSerie = [{
    name: 'Ingresos',
    data: [3000, 4000, 3500, 5000, 4900, 2000]
  }];

  const marcasOptions = {
    labels: ['Acer', 'HP', 'Asus', 'Lenovo'],
    colors: ['#008FFB', '#00E396', '#FEB019', '#FF4560']
  };

  const marcasSeries = [32, 70, 18, 27];

  const movimientosOptions = {
    labels: ['Ingreso: Permanente', 'Ingreso: Ocasional'],
    colors: ['#008FFB', '#FF4560']
  };

  const movimientosSeries = [286, 123];

  return (
    <div className="dashboard-content">
      <h1 className="dashboard-title">Dashboard de Movimientos</h1>

      {/* Primera fila: Resumen de ganancias */}
      <div className="dashboard-row">
        <div className="dashboard-card large">
          <div className="card-header">
            <FontAwesomeIcon icon={faChartLine} className="card-icon" />
            <h3>Grafico de Total de Ingresos</h3>
          </div>
          <Chart
            options={ventasOptions}
            series={ingresosSerie}
            type="area"
            height={250}
          />
          <div className="time-filters justify-content-end">
            <button className="active">Exportar <FontAwesomeIcon icon={faFilePdf} /></button>
          </div>
        </div>
      </div>

      {/* Segunda fila: Servicios y equipos */}
      <div className="dashboard-row">
        <div className="dashboard-card">
          <div className="card-header">
            <FontAwesomeIcon icon={faComputer} className="card-icon" />
            <h3>Porcentaje de Marcas</h3>
          </div>
          <Chart
            options={marcasOptions}
            series={marcasSeries}
            type="donut"
            height={250}
          />
          <div className="time-filters justify-content-end">
            <button className="active">Exportar <FontAwesomeIcon icon={faFilePdf} /></button>
          </div>
        </div>

        <div className="dashboard-card">
          <div className="card-header">
            <FontAwesomeIcon icon={faRightLong} className="card-icon" />
            <h3>Porcentaje de Ingresos</h3>
          </div>
          <Chart
            options={movimientosOptions}
            series={movimientosSeries}
            type="donut"
            height={250}
          />
          <div className="time-filters justify-content-end">
            <button className="active">Exportar <FontAwesomeIcon icon={faFilePdf} /></button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;