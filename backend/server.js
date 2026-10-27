const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Request logger middleware
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${req.method} ${req.url}`);
  next();
});

// Mock In-Memory State
const INITIAL_BALANCE = 24850.50;
const VALID_TOKEN = 'mock_access_token_123';

let currentUser = {
  id: 'USR10001',
  name: 'Ajay Dwivedi',
  email: 'demo@jstack.co'
};

let currentWallet = {
  walletId: 'WALLET10001',
  currency: 'INR',
  availableBalance: INITIAL_BALANCE,
  maskedAccountNumber: 'XXXX XXXX 4589'
};

let initialTransactions = [
  {
    id: 'TXN-984210488219',
    type: 'DEBIT',
    amount: 1500.00,
    currency: 'INR',
    beneficiaryName: 'Rahul Sharma',
    status: 'SUCCESS',
    createdAt: new Date(Date.now() - 3600000).toISOString(),
    remarks: 'Dinner & groceries split',
    mobileNumber: '9876543210',
    category: 'P2P'
  },
  {
    id: 'TXN-984205118902',
    type: 'DEBIT',
    amount: 340.00,
    currency: 'INR',
    beneficiaryName: 'Blue Tokai Coffee',
    status: 'SUCCESS',
    createdAt: new Date(Date.now() - 14400000).toISOString(),
    remarks: 'POS Terminal 12',
    category: 'MERCHANT'
  },
  {
    id: 'TXN-984180491823',
    type: 'CREDIT',
    amount: 45000.00,
    currency: 'INR',
    beneficiaryName: 'Salary Deposit (JStack)',
    status: 'SUCCESS',
    createdAt: new Date(Date.now() - 86400000).toISOString(),
    remarks: 'JStack Technologies Monthly Payroll',
    category: 'NEFT'
  },
  {
    id: 'TXN-984166291040',
    type: 'DEBIT',
    amount: 480.00,
    currency: 'INR',
    beneficiaryName: 'Swiggy Instant',
    status: 'SUCCESS',
    createdAt: new Date(Date.now() - 100800000).toISOString(),
    remarks: 'Order #SWG-8912',
    category: 'DINING'
  },
  {
    id: 'TXN-984155104822',
    type: 'CREDIT',
    amount: 240.00,
    currency: 'INR',
    beneficiaryName: 'Uber India Refund',
    status: 'SUCCESS',
    createdAt: new Date(Date.now() - 115200000).toISOString(),
    remarks: 'Ride fare adjustment refund',
    category: 'REFUND'
  },
  {
    id: 'TXN-984099281033',
    type: 'CREDIT',
    amount: 150.00,
    currency: 'INR',
    beneficiaryName: 'Cashback Reward',
    status: 'SUCCESS',
    createdAt: new Date(Date.now() - 172800000).toISOString(),
    remarks: 'jWallet Auto-Perks Cash bonus',
    category: 'BONUS'
  },
  {
    id: 'TXN-984012984920',
    type: 'DEBIT',
    amount: 2100.00,
    currency: 'INR',
    beneficiaryName: 'Priya Nair',
    status: 'SUCCESS',
    createdAt: new Date(Date.now() - 194400000).toISOString(),
    remarks: 'Weekend road trip expenses',
    mobileNumber: '9811233445',
    category: 'P2P'
  },
  {
    id: 'TXN-983988410284',
    type: 'DEBIT',
    amount: 620.00,
    currency: 'INR',
    beneficiaryName: 'Zomato Online',
    status: 'SUCCESS',
    createdAt: new Date(Date.now() - 259200000).toISOString(),
    remarks: 'Order #ZM-8419',
    category: 'DINING'
  },
  {
    id: 'TXN-983902910488',
    type: 'DEBIT',
    amount: 1380.00,
    currency: 'INR',
    beneficiaryName: 'Electricity Bill (BESCOM)',
    status: 'SUCCESS',
    createdAt: new Date(Date.now() - 273600000).toISOString(),
    remarks: 'Consumer #5589124',
    category: 'UTILITY'
  },
  {
    id: 'TXN-983811902834',
    type: 'CREDIT',
    amount: 5000.00,
    currency: 'INR',
    beneficiaryName: 'Amit Kumar',
    status: 'SUCCESS',
    createdAt: new Date(Date.now() - 432000000).toISOString(),
    remarks: 'Freelance project milestone',
    mobileNumber: '9765432109',
    category: 'P2P'
  }
];

let transactions = [...initialTransactions];

// Database Persistence (JSON file backup)
const DB_PATH = path.join(__dirname, 'database.json');

function saveDb() {
  try {
    fs.writeFileSync(DB_PATH, JSON.stringify({
      currentWallet,
      transactions,
    }, null, 2));
  } catch (err) {
    console.error('[DB] Error persisting database:', err.message);
  }
}

function loadDb() {
  try {
    if (fs.existsSync(DB_PATH)) {
      const raw = fs.readFileSync(DB_PATH, 'utf8');
      const data = JSON.parse(raw);
      if (data.currentWallet) currentWallet = data.currentWallet;
      if (Array.isArray(data.transactions) && data.transactions.length > 0) {
        transactions = data.transactions;
      }
      console.log(`[DB] Restored state from disk: Balance ₹${currentWallet.availableBalance}, ${transactions.length} transactions`);
    }
  } catch (err) {
    console.error('[DB] Error loading persisted database:', err.message);
  }
}

// Initial load from disk if present
loadDb();

// Idempotency Cache: key -> { payload, response }
const idempotencyStore = new Map();

// Helper: Consistent error response builder
function errorResponse(res, status, code, message) {
  return res.status(status).json({
    success: false,
    error: {
      code,
      message
    }
  });
}

// Auth Middleware
function requireAuth(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return errorResponse(res, 401, 'UNAUTHORIZED', 'Authentication token is missing or malformed');
  }

  const token = authHeader.split(' ')[1];
  if (token !== VALID_TOKEN) {
    return errorResponse(res, 401, 'INVALID_TOKEN', 'Session has expired or token is invalid');
  }

  next();
}

// -------------------------------------------------------------
// ENDPOINTS
// -------------------------------------------------------------

// API 1: Login
app.post('/api/v1/auth/login', (req, res) => {
  const { email, password } = req.body || {};

  if (!email || !password) {
    return errorResponse(res, 400, 'INVALID_REQUEST', 'Email and password are required');
  }

  if (email.trim().toLowerCase() === 'demo@jstack.co' && password === 'Demo@123') {
    console.log(`[AUTH 200] Generated Token: "${VALID_TOKEN}" for ${currentUser.email}`);
    return res.status(200).json({
      success: true,
      data: {
        accessToken: VALID_TOKEN,
        user: currentUser
      }
    });
  }

  return errorResponse(res, 401, 'INVALID_CREDENTIALS', 'Invalid email or password');
});

// API 2: User Profile
app.get('/api/v1/users/profile', requireAuth, (req, res) => {
  return res.status(200).json({
    success: true,
    data: currentUser
  });
});

// API 3: Wallet Balance
app.get('/api/v1/wallet/balance', requireAuth, (req, res) => {
  return res.status(200).json({
    success: true,
    data: {
      walletId: currentWallet.walletId,
      currency: currentWallet.currency,
      availableBalance: parseFloat(currentWallet.availableBalance.toFixed(2)),
      maskedAccountNumber: currentWallet.maskedAccountNumber
    }
  });
});

// API 4: Transaction History
app.get('/api/v1/transactions', requireAuth, (req, res) => {
  // Sorted in descending chronological order
  const sorted = [...transactions].sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  return res.status(200).json({
    success: true,
    data: sorted
  });
});

// API 5: Money Transfer (with Idempotency)
app.post('/api/v1/transactions/transfer', requireAuth, (req, res) => {
  const idempotencyKey = req.headers['idempotency-key'];
  const { beneficiaryName, mobileNumber, amount, remarks } = req.body || {};

  // Check Idempotency Key
  if (idempotencyKey && idempotencyStore.has(idempotencyKey)) {
    console.log(`[Idempotency Hit] Replaying cached response for key: ${idempotencyKey}`);
    const cached = idempotencyStore.get(idempotencyKey);
    return res.status(200).json(cached);
  }

  // Field validation
  if (!beneficiaryName || typeof beneficiaryName !== 'string' || beneficiaryName.trim().length < 3) {
    return errorResponse(res, 400, 'INVALID_BENEFICIARY', 'Beneficiary name must be at least 3 characters');
  }

  const cleanMobile = String(mobileNumber || '').replace(/\D/g, '');
  if (cleanMobile.length !== 10) {
    return errorResponse(res, 400, 'INVALID_MOBILE', 'Beneficiary mobile must be a valid 10-digit number');
  }

  const numAmount = parseFloat(amount);
  if (isNaN(numAmount) || numAmount <= 0) {
    return errorResponse(res, 400, 'INVALID_AMOUNT', 'Transfer amount must be greater than zero');
  }

  // Check available balance
  if (numAmount > currentWallet.availableBalance) {
    const failedTxId = `TXN-${Date.now().toString().slice(3)}`;
    const failedTx = {
      id: failedTxId,
      type: 'DEBIT',
      amount: numAmount,
      currency: 'INR',
      beneficiaryName: beneficiaryName.trim(),
      status: 'FAILED',
      createdAt: new Date().toISOString(),
      remarks: 'Insufficient Funds',
      mobileNumber: cleanMobile,
      category: 'P2P'
    };

    // Record failed transaction in history
    transactions.unshift(failedTx);
    saveDb();

    return errorResponse(
      res,
      409,
      'INSUFFICIENT_BALANCE',
      `Insufficient Funds: Available balance is ₹${currentWallet.availableBalance.toFixed(2)}`
    );
  }

  // Authoritative server balance deduction
  currentWallet.availableBalance = parseFloat((currentWallet.availableBalance - numAmount).toFixed(2));

  // Generate unique transaction reference
  const transactionId = `TXN-${Date.now().toString().slice(3)}`;
  const newTx = {
    id: transactionId,
    type: 'DEBIT',
    amount: numAmount,
    currency: 'INR',
    beneficiaryName: beneficiaryName.trim(),
    status: 'SUCCESS',
    createdAt: new Date().toISOString(),
    remarks: (remarks && remarks.trim() !== '') ? remarks.trim() : 'NA',
    mobileNumber: cleanMobile,
    category: 'P2P'
  };

  // Add to history
  transactions.unshift(newTx);
  saveDb();

  const responsePayload = {
    success: true,
    data: {
      transactionId,
      status: 'SUCCESS',
      amount: numAmount,
      currency: 'INR',
      availableBalance: currentWallet.availableBalance
    }
  };

  // Save in idempotency store
  if (idempotencyKey) {
    idempotencyStore.set(idempotencyKey, responsePayload);
  }

  return res.status(200).json(responsePayload);
});

// API 6: Transaction Details
app.get('/api/v1/transactions/:id', requireAuth, (req, res) => {
  const { id } = req.params;
  const found = transactions.find(t => t.id === id);

  if (!found) {
    return errorResponse(res, 404, 'TRANSACTION_NOT_FOUND', `Transaction with ID '${id}' was not found`);
  }

  return res.status(200).json({
    success: true,
    data: found
  });
});

// Reset endpoint for testing
app.post('/api/v1/reset', (req, res) => {
  currentWallet.availableBalance = INITIAL_BALANCE;
  transactions = [...initialTransactions];
  idempotencyStore.clear();
  saveDb();
  return res.status(200).json({ success: true, message: 'State reset successfully' });
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'jWallet Lite Mock API' });
});

// Start Server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`===============================================`);
  console.log(` jWallet Lite Mock REST API running on port ${PORT}`);
  console.log(` Local:    http://localhost:${PORT}`);
  console.log(` Android:  http://10.0.2.2:${PORT}`);
  console.log(`===============================================`);
});
