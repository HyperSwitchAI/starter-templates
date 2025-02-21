mod common;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenv::dotenv()?;
    
    println!("HyperSwitch AI API Examples");
    Ok(())
}
