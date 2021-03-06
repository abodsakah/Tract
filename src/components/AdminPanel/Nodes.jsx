/* ---------------------------------- React --------------------------------- */
import React from 'react'

/* ----------------------------------- MUI ---------------------------------- */
import {Box, Typography, Paper, Divider, Table, TableHead, TableRow, TableCell, TableBody, TableContainer, Button} from '@mui/material'

/* ------------------------------ React router ------------------------------ */
import {Link} from 'react-router-dom'

function Nodes({t, apiURL}) {
    const [nodes, setNodes] = React.useState([])
    const [fetched, setFetched] = React.useState(false)

    if (!fetched) {
        fetch(`${apiURL}/getNodes?key=${process.env.REACT_APP_TRACT_API_KEY}`).then(res => res.json()).then(
            (result) => {
                setNodes(result)
                setFetched(true)
            }
        )
    }

    return (
        <Box m={2}>
            <Typography variant="h4" gutterBottom>{t('nodes')}</Typography>
            <Divider />
            < br />

            <Button variant="outlined" style={{ float: 'left',
              marginBottom: '2rem',
              marginTop: '1rem',
              }} component={Link} to="/admin/add-node">{t('addNode')}</Button>
            {nodes.length > 0 ? 
                <>
                <TableContainer component={Paper}>
                    <Table aria-label="simple table">
                        <TableHead>
                            <TableRow>
                                <TableCell>{t('nodeId')}</TableCell>
                                <TableCell>{t('nodeType')}</TableCell>
                                <TableCell>{t('nodeCompany')}</TableCell>
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            {nodes.map((node) => (
                                <TableRow key={node.uid}>
                                    <TableCell component="th" scope="row">
                                        {node.uid}
                                    </TableCell>
                                    <TableCell>{node.type}</TableCell>
                                    <TableCell>{node.company_id}</TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                </TableContainer>
                    </>
                :
                <Typography variant="h5">{t('noNodes')}</Typography>
            }
        </Box>
    )

}

export default Nodes