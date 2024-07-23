use anchor_lang::prelude::*;

declare_id!("CXWFKP9QBo5r2pYyJy8p27YFXzYcj39CcbrygQCXRENx");

#[program]
// Smart contract functions
pub mod airdrop {
    use super::*;
    pub fn create_counter(
        ctx: Context<CreateCounter>,
        //存入的数量,填0
        amount: f64,
        //是否可以领取ido,填false
        can_airdrop: bool,
        //是否可以领取空头，填false
        can_ido: bool,
    ) -> Result<()> {
        msg!("Creating a Counter!!");
        let counter = &mut ctx.accounts.counter;
        counter.authority = ctx.accounts.authority.key();
        counter.amount = amount;
        counter.can_airdrop = can_airdrop;
        counter.can_ido = can_ido;
        // The creation of the counter must be here
        msg!("The Admin PubKey is: {} ", counter.authority);
        Ok(())
    }
    pub fn update_counter(
        ctx: Context<UpdateCounter>,
        //用户ido的sol的数量，用户先在前端进行转账，然后更新这个值
        amount: f64,
        //管理员启动ido的按钮,如果pda账号里面有这个值为true就是用户可以进行ido了
        can_airdrop: bool,
        //是否已经领取过ido了,最开始值为false,领取过后变成true,每次领取之前前端先拿到pda账户判断一下
        can_ido: bool,
    ) -> Result<()> {
        msg!("Adding 1 to the counter!!");
        // Updating the counter must be here
        let counter = &mut ctx.accounts.counter;
        counter.authority = ctx.accounts.authority.key();
        counter.amount = amount;
        counter.can_airdrop = can_airdrop;
        counter.can_ido = can_ido;
        Ok(())
    }
}

// Data validators
#[derive(Accounts)]
pub struct CreateCounter<'info> {
    #[account(mut)]
    authority: Signer<'info>,
    #[account(
        init,
        seeds = [authority.key().as_ref()],
        bump,
        payer = authority,
        space = 100
    )]
    counter: Account<'info, Airdrop>,
    system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct UpdateCounter<'info> {
    authority: Signer<'info>,
    #[account(mut, has_one = authority)]
    counter: Account<'info, Airdrop>,
}

// Data structures
#[account]
pub struct Airdrop {
    authority: Pubkey,
    amount: f64,
    can_airdrop: bool,
    can_ido: bool,
}

