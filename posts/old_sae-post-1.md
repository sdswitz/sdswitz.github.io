---
title: SAE Project v1
date: March 23, 2026
---

In this post I'll describe my process of writing a basic Sparse Autoencoder (SAE) from scratch.

The code for the model:

```
def SAEloss(xhat, x, f, lam=1e-3):
    return F.mse_loss(xhat, x) + lam * f.abs().mean()

class SparseAutoEncoder(nn.Module):
    def __init__(self, d, m):
        super().__init__()
        self.b_pre = nn.Parameter(torch.zeros(d))
        self.b_enc = nn.Parameter(torch.zeros(m))
        self.W_enc = nn.Parameter(torch.nn.init.xavier_normal_(torch.empty(d,m)))
        self.W_dec = nn.Parameter(torch.nn.init.xavier_normal_(torch.empty(m,d)))
        self.W_dec = nn.Parameter(self.W_dec / self.W_dec.norm(dim=1, keepdim=True))
        
        self.act = nn.ReLU()
        
    def encoder(self, x):
        x = x - self.b_pre
        x = x @ self.W_enc
        x = x + self.b_enc
        x = self.act(x)
        return x
    
    def decoder(self, f):
        xhat = f @ self.W_dec
        xhat = xhat + self.b_pre
        return xhat
    
    def forward(self, x):
        f = self.encoder(x)
        xhat = self.decoder(f)
        return xhat, f
```

I then trained a few models on the residual stream of the third block in the Pythia 70M model. I used 4x, 8x, 16x and 32x factor expansions.

## Results

In the 4x factor expansion, I found feature 1896 to be fairly interesting; all of the top-activating tokens were names for cities or states (e.g. ' Angeles', ' Georgia', ' York', ' Francisco', ' Paris', etc.). It's also worth noting that I did not find this feature by looking at the sparsest features in my model, but rather by looking at features whose top-20 activating tokens matched a given query, in this case "paris". Despite the fact that all of the top-20 features were active, the fact that this feature had different tokens that all had similar meanings made we want to investigate it further via ablation.

I then wrote a simple sentence that involved "New York" to see how the distribution of predicted tokens would change at each point in the sentence. These were the results:

```
KL divergence per token:

 0   <|endoftext|>  KL=0.000000
 1             The  KL=0.000000
 2        governor  KL=0.000000
 3              of  KL=0.000000
 4             New  KL=0.000000
 5            York  KL=0.072997
 6       announced  KL=-0.000000
 7     legislation  KL=0.000000
 8              to  KL=0.000001
 9         improve  KL=0.000080
10          public  KL=0.000004
11  transportation  KL=0.000006
12              in  KL=0.005954
13             the  KL=0.005579
14           state  KL=0.025738
15               .  KL=0.000357
```

The most notable differences are on the tokens "York" and "state", which make intuitive sense to me since 1) " York" is the specific token we ablated out, and 2) " state" is the most relevant token to " York" that comes after it in the sentence. The fact that " governor" appears early in the sentence likely plays a role in this.

Here are the top 5 next tokens for the clean vs ablated processes after "York":

```
Position 5: ' York'
  Clean:   [' City', ' is', ',', ' has', ' State']
  Ablated: [' City', ' State', ' is', ' has', ' state']
```

Ultimately, "City" has the highest probability of coming next under both models, but we can see that the other tokens in the top 5 changes a little bit. So it appears that our feature is capturing something, but not much. This makes sense though because we are looking at a relatively early layer in the model