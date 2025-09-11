const express = require('express');
const jwt = require('jsonwebtoken');
const app = express();

const SECRET = 'mysecret';

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

app.post('/token', (req, res) => {
  const { client_id, client_secret } = req.body;

  console.log(client_id);
  console.log(client_secret);

  // Simulação de "database" de clientes
  const clients = {
    test: {
      secret: 'secret',
      scope: 'read write profile'
    },
    admin: {
      secret: 'adminsecret',
      scope: 'admin:users admin:settings'
    }
  };

  const client = clients[client_id];

  if (client && client.secret === client_secret) {
    const token = jwt.sign(
      { sub: client_id, scope: client.scope },
      SECRET,
      { expiresIn: '1h' }
    );
    res.json({ access_token: token, token_type: 'Bearer', expires_in: 3600 });
  } else {
    res.status(401).json({ error: 'Invalid client credentials' });
  }
});

app.get('/me', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing or malformed token' });
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, SECRET);
    res.json({ client_id: decoded.sub, scope: decoded.scope });
  } catch (err) {
    res.status(403).json({ error: 'Invalid token' });
  }
});

app.listen(3000, () => console.log('Fake OAuth Server on http://localhost:3000'));
