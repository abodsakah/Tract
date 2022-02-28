import {CircularProgress, Typography} from '@mui/material';
import * as React from 'react';
import { styled } from '@mui/material/styles';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell, { tableCellClasses } from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Paper from '@mui/material/Paper';
import Box from '@mui/material/Box';
import Fab from '@mui/material/Fab';
import AddIcon from '@mui/icons-material/Add';
import PropTypes from 'prop-types';
import Tabs from '@mui/material/Tabs';
import Tab from '@mui/material/Tab';
import UserID from './UserID';
import Footer from './Footer';




const Index = ({text, cookies, t}) => {

    const [value, setValue] = React.useState(0);
  
    const handleChange = (event, newValue) => {
      setValue(newValue);
    };

    
    const StyledTableCell = styled(TableCell)(({ theme }) => ({
        [`&.${tableCellClasses.head}`]: {
        backgroundColor: '#D3D3D3',
        fontFamily: 'Bungee Inline',
        fontSize: 20,
        color: 'black',
        },
        [`&.${tableCellClasses.body}`]: {
        fontSize: 17,
        font: 'bold',
        },
    }));
    
    const StyledTableRow = styled(TableRow)(({ theme }) => ({
        '&:nth-of-type(odd)': {
        backgroundColor: 'white',
        },
        // hide last border
        '&:last-child td, &:last-child th': {
        border: 0,
        },
    }));
    
    function createData(name, datum, ID, Antal) {
        return { name, datum, ID, Antal};
    }
    
    const rows = [
        createData('Dörrsensorer', '23 feb 2022', '218-9', '13'),
        createData('Hisssensorer', '13 aug 2022', '216-2', '9'),
        createData('Temperaturesensorer', '5 mars 2022', '221-6', '2'),
        createData('Sensor D', '22 feb 2022', '321-5', '1'),
        createData('Sensor H', '1 jan 2022', '431-80', '1'),
    ];
    
    function TabPanel(props) {
        const { children, value, index, ...other } = props;
    
    return (
        <div
            role="tabpanel"
            hidden={value !== index}
            id={`simple-tabpanel-${index}`}
            aria-labelledby={`simple-tab-${index}`}
            {...other}
        >
            {value === index && (
            <Box sx={{ p: 3 }}>
                <Typography>{children}</Typography>
            </Box>
            )}
        </div>
        );
    }
    
    TabPanel.propTypes = {
        children: PropTypes.node,
        index: PropTypes.number.isRequired,
        value: PropTypes.number.isRequired,
    };
    
    function a11yProps(index) {
        return {
        id: `simple-tab-${index}`,
        'aria-controls': `simple-tabpanel-${index}`,
        };
    }
    
    return (
        <main>
            {/* logo */}
        <div style={{ position: 'relative', textAlign: 'center' }}>
         <img src={require('./static/images/logo_tract.png')} />
       </div>
            <UserID cookies={cookies} t={t}/>
                {/* ADD-BUTTONS */}
                <div style={{ textAlign: 'right', backgroundColor: 'white', padding: '1rem', }} >
                <Box style={{ textAlign: '' }} sx={{ '& > :not(style)': { m: 1 } }}>
                    <Fab style={{ backgroundColor: '#32CECF', '&:hover': { backgroundColor: '#E81A76' } }} aria-label="add">
                    <AddIcon />
                    </Fab>
                    <h2>{t("addSensor")}</h2>
                    </Box>
                </div>

    
            {/* List */}
            <div style={{ borderCollapse:'separate', borderRadius: '3rem', boxShadow: '5px 3px 5px 5px #d3d3d3' }}>
            <Box sx={{ width: '100%' }}> 
            <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
                <Tabs value={value} onChange={handleChange} aria-label="basic tabs example">
                <Tab label={t("mostRecent")} {...a11yProps(0)} />
            {/*    <Tab label="Ofta rapporterade" {...a11yProps(1)} />
                <Tab label="Nyligen installerade" {...a11yProps(2)} />*/}
                </Tabs>
            </Box>
            <TabPanel value={value} index={0}>
                {/* TABLE */}
                <TableContainer component={Paper}>
                <Table sx={{ minWidth: 150 }} aria-label="customized table">
                    <TableHead>
                    <TableRow>
                        <StyledTableCell>{t("sensor")}</StyledTableCell>
                        <StyledTableCell align="right">{t("articleNumber")}</StyledTableCell>
                        <StyledTableCell align="right">{t("date")}</StyledTableCell>
                        <StyledTableCell align="right">{t("amount")}</StyledTableCell>
                    </TableRow>
                    </TableHead>
                    <TableBody>
                    {rows.map((row) => (
                        <StyledTableRow key={row.name}>
                        <StyledTableCell component="th" scope="row"> {row.name}</StyledTableCell>
                        <StyledTableCell align="right">{row.ID}</StyledTableCell>
                        <StyledTableCell align="right">{row.datum}</StyledTableCell>
                        <StyledTableCell align="right">{row.Antal}</StyledTableCell>
                        </StyledTableRow>
                    ))}
                    </TableBody>
                </Table>
                </TableContainer>
            </TabPanel>
            <TabPanel value={value} index={1}>
                Item Two
            </TabPanel>
            <TabPanel value={value} index={2}>
                Item Three
            </TabPanel>
            </Box>
        
            </div>
            <Footer />
    </main>
    );

                }

    export default Index;

