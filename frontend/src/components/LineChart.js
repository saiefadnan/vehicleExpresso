import '../styles/chart.css'
import { Chart, scales } from "chart.js/auto";
import { useEffect, useRef, useState } from "react";
import useFetchData from '../context/useFetchData';

const LineCharts = () => {
    const chartRef = useRef(null);
    const chartInstance = useRef(null);
    const [year, setYear] = useState('2022');
    const [month, setMonth] = useState('ALL');
    const [values,setValues] = useState([]);
    const [labels,setLabels] = useState([]);
    const [linedata,setLinedata] = useState([]);
    const [error,setError]=useState(null);
    const [title,setTitle]=useState('Total Service Cost Analysis(Per Month)');
    const url= `http://localhost:4000/api/care/linedata`;

    const handleselectChange =(event)=>{
        if(event.target.childElementCount===13) setMonth(event.target.value);
        else setYear(event.target.value);
    }
    

    useEffect(()=>{
        const fetchData = async () => {
          try {
            const response = await fetch(url,
                {
                    method: 'POST',
                    headers: {
                        'Content-Type':'application/json',
                    },
                    body: JSON.stringify({year:year,month:month})
                }
            );
            if (!response.ok) throw new Error('Failed to fetch data');
            const jsonData = await response.json();
            setLinedata(jsonData);
            setError(null);
          }catch(err){
            console.error('Error fetching data : ',err);
            setError(err.message);
          }
        };
        fetchData();
      },[month,year]);


    useEffect(()=>{
        if(!error && linedata.monthCost && Array.isArray(linedata.monthCost)){ 
            const LineLabel =linedata.monthCost.map(line=>{return Object.keys(line)[0]});
            const LineData =linedata.monthCost.map(line=>{return Object.values(line)[0]});
            setLabels(LineLabel);
            setValues(LineData);
            setTitle('Total Service Cost Analysis(Per Month)');
        }
        else if(!error && linedata.dayCost && Array.isArray(linedata.dayCost)){ 
            const LineLabel =linedata.dayCost.map(line=>{return Object.keys(line)[0]});
            const LineData =linedata.dayCost.map(line=>{return Object.values(line)[0]});
            setLabels(LineLabel);
            setValues(LineData);
            setTitle('Total Service Cost Analysis(Per Day)');
        }
    },[error,linedata])

    const mdata = {
        labels: labels,
        datasets: [{
            label: title,
            data: values,
            fill: true,
            borderColor: 'rgba(144, 238, 144, 1)',
            backgroundColor: 'rgba(144, 238, 144, 0.2)',
            tension: 0.4
        }]
    };
    useEffect(()=>{
        if(chartInstance.current){
            chartInstance.current.destroy();
        }
        const mychartRef = chartRef.current.getContext("2d");

        chartInstance.current =new Chart(mychartRef,{
            type: 'line',
            data: mdata,
            options:{
                scale:{
                    y:{
                        min:0
                    }
                },
                responsive: true,
                maintainAspectRatio: false,
                
           }
        })
            return ()=>{
                if(chartInstance.current){
                    chartInstance.current.destroy();
                }
            }
        },[values,labels])
    return (
        <div className="linechart-container">
            <div className='option1'>
                <span>Select Year </span>
                <select className="select" value={year} onChange={handleselectChange}>
                    <option value="2022">2022</option>
                    <option value="2023">2023</option>
                    <option value="2024">2024</option>
                </select>
            </div>
            <div className='option2'>
                <span>Select Month </span>
                    <select className="select" value={month} onChange={handleselectChange}>
                    <option value="ALL">ALL</option>
                    <option value="JAN">JAN</option>
                    <option value="FEB">FEB</option>
                    <option value="MAR">MAR</option>
                    <option value="APR">APR</option>
                    <option value="MAY">MAY</option>
                    <option value="JUN">JUN</option>
                    <option value="JUL">JUL</option>
                    <option value="AUG">AUG</option>
                    <option value="SEP">SEP</option>
                    <option value="OCT">OCT</option>
                    <option value="NOV">NOV</option>
                    <option value="DEC">DEC</option>
                </select>
            </div>
            <canvas ref={chartRef}/>
        </div>
    )
}
 
export default LineCharts;