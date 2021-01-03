const express = require("express");
const cors = require("cors");
const morgan = require("morgan");
const helmet = require("helmet");
const jwt = require("express-jwt");
const jwksRsa = require("jwks-rsa");

const authConfig = {
  domain: process.env.AUTH_CONFIG_DOMAIN,
  clientId: process.env.AUTH_CONFIG_CLIENTID,
  audience: process.env.AUTH_CONFIG_AUDIENCE,
  appOrigin: process.env.APP_ORIGIN ? process.env.APP_ORIGIN.split(',') : []
};

const app = express();

const port = process.env.PORT || 3001;
const appOrigin = authConfig.appOrigin;

if (!authConfig.domain || !authConfig.audience) {
  throw new Error(
    "Please make sure that auth_config.json is in place and populated"
  );
}

app.use(morgan("dev"));
app.use(helmet());
app.use(cors({ origin: appOrigin }));

const checkJwt = jwt({
  secret: jwksRsa.expressJwtSecret({
    cache: true,
    rateLimit: true,
    jwksRequestsPerMinute: 5,
    jwksUri: `https://${authConfig.domain}/.well-known/jwks.json`
  }),

  audience: authConfig.audience,
  issuer: `https://${authConfig.domain}/`,
  algorithms: ["RS256"]
});

app.get("/api/external", checkJwt, (req, res) => {
  res.send({
    msg: "Your access token was successfully validated!"
  });
});

app.get('/healthz', (req, res) => {
  res.send({
    status: 'healthy'
  });
})

app.listen(port, () => console.log(`API Server listening on port ${port}`));
