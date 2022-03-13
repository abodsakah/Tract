import {Box, Button, Divider, Grid, Typography, styled, TextField} from '@mui/material'
import React, {useEffect} from 'react'
import LoadingOverlay from '../LoadingOverlay';

function AddCompany({t, color}) {

  const [companyName, setCompanyName] = React.useState('');
  const [companyEmail, setCompanyEmail] = React.useState('');
  const [companyPhone, setCompanyPhone] = React.useState('');
  const [companyAdminMail, setCompanyAdminMail] = React.useState('');
  const [companyAdminFName, setCompanyAdminFName] = React.useState('');
  const [companyAdminLName, setCompanyAdminLName] = React.useState('');
  const [companyAdminUser, setCompanyAdminUser] = React.useState('');
  const [loading, setLoading] = React.useState(false);

  let createAPI = () => {
    fetch(`http://localhost:9000/api/createCompany?key=${process.env.REACT_APP_TRACT_API_KEY}&name=${companyName}&email=${companyEmail}&phone=${companyPhone}&adminmail=${companyAdminMail}&adminfirstname=${companyAdminFName}&adminlastname=${companyAdminLName}&adminusername=${companyAdminUser}`)
      .then(res => res.json())
      .then(res => {
        console.log(res);
        if (res.status === "success") {
          setLoading(false);
        }
      })
  }

  let ValidateAndSubmit = () => {
    if (companyName === '' || companyEmail === '' || companyPhone === '' || companyAdminMail === '' || companyAdminFName === '' || companyAdminLName === '' || companyAdminUser === '') {
      alert('Please fill all the fields');
    } else {
      setLoading(true);
      createAPI();
    }
  }

  const StyledTextField = styled(TextField)({
    width: '100%',
    '& label.Mui-focused': {
      color: color,
    },
    '& .MuiInput-underline:after': {
      borderBottomColor: color,
    },
    '& .MuiOutlinedInput-root': {
      '&.Mui-focused fieldset': {
        borderColor: color,
      },
    },
  });

  return (
    <Box m={2}>
      <LoadingOverlay loading={loading} />
        <Typography variant="h4">Add Company</Typography>
        <br />
        <Divider />
        <br />
        <Typography variant="h6">{t('companiesInformation')}</Typography>
        <br />
        <Grid container spacing={3}>
          <Grid item xs={12} md={4}>
            <StyledTextField
              id="outlined-basic"
              label={t('companyName')}
              variant="outlined"
              style={{width: '100%'}}
              onChange={(e) => setCompanyName(e.target.value)}
            />
          </Grid>
          <Grid item xs={12} md={4}>
            <StyledTextField
              id="outlined-basic"
              label={t('supportEmail')}
              variant="outlined"
              style={{width: '100%'}}
              onChange={(e) => setCompanyEmail(e.target.value)}
            />
        </Grid>
        <Grid item xs={12} md={4}>
          <StyledTextField
            id="outlined-basic"
            label={t('supportPhone')}
            variant="outlined"
            style={{width: '100%'}}
            onChange={(e) => setCompanyPhone(e.target.value)}
          />
          </Grid>
      </Grid>
      <br />
      <Typography variant="h6">{t('companyAdminInformation')}</Typography>
      <br />
      <Grid container spacing={3}>
        <Grid item xs={12} md={6}>
          <StyledTextField
            id="outlined-basic"
            label={t('adminFirstName')}
            variant="outlined"
            onChange={(e) => setCompanyAdminFName(e.target.value)}
          />
        </Grid>
        <Grid item xs={12} md={6}>
          <StyledTextField
            id="outlined-basic"
            label={t('adminLastName')}
            variant="outlined"
            onChange={(e) => setCompanyAdminLName(e.target.value)}
          />
        </Grid>
        <Grid item xs={12} md={6}>
          <StyledTextField
            id="outlined-basic"
            label={t('adminMail')}
            variant="outlined"
            onChange={(e) => setCompanyAdminMail(e.target.value)}
          />
        </Grid>
        <Grid item xs={12} md={6}>
          <StyledTextField
            id="outlined-basic"
            label={t('adminUsername')}
            variant="outlined"
            onChange={(e) => setCompanyAdminUser(e.target.value)}
          />
        </Grid>
      </Grid>
      <br />
      <Button variant="outlined" style={{width: '100%', borderColor: color, color: color}}  onClick={() => ValidateAndSubmit()}>
        {t('addCompany')}
      </Button>
      </Box>
  )
}

  export default AddCompany